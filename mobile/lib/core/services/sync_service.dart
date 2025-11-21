import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pet_model.dart';
import '../models/health_record_model.dart';
import '../models/weight_entry_model.dart';
import '../models/care_plan_model.dart';
import '../utils/api_client.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiClient _apiClient = ApiClient();
  Database? _database;
  bool _isSyncing = false;
  bool _hasNetworkConnection = true;

  // Initialize sync service and local database
  Future<void> initialize() async {
    await _initDatabase();
    await _checkNetworkConnection();
    await _startPeriodicSync();
  }

  // Initialize local SQLite database for offline storage
  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pet_support_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create pets table
        await db.execute('''
          CREATE TABLE pets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            breed TEXT,
            age INTEGER,
            weight REAL,
            gender TEXT,
            profile_image_url TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_sync_at TEXT,
            is_synced INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0
          )
        ''');

        // Create health records table
        await db.execute('''
          CREATE TABLE health_records (
            id TEXT PRIMARY KEY,
            pet_id TEXT NOT NULL,
            record_type TEXT NOT NULL,
            description TEXT,
            date TEXT NOT NULL,
            veterinarian_name TEXT,
            notes TEXT,
            attachments TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_sync_at TEXT,
            is_synced INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0,
            FOREIGN KEY (pet_id) REFERENCES pets (id)
          )
        ''');

        // Create weight entries table
        await db.execute('''
          CREATE TABLE weight_entries (
            id TEXT PRIMARY KEY,
            pet_id TEXT NOT NULL,
            weight REAL NOT NULL,
            date TEXT NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_sync_at TEXT,
            is_synced INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0,
            FOREIGN KEY (pet_id) REFERENCES pets (id)
          )
        ''');

        // Create care plans table
        await db.execute('''
          CREATE TABLE care_plans (
            id TEXT PRIMARY KEY,
            pet_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            tasks TEXT,
            start_date TEXT NOT NULL,
            end_date TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_sync_at TEXT,
            is_synced INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0,
            FOREIGN KEY (pet_id) REFERENCES pets (id)
          )
        ''');

        // Create sync queue table for tracking pending operations
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            operation TEXT NOT NULL,
            data TEXT,
            timestamp TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');

        // Create indexes for better performance
        await db.execute('CREATE INDEX idx_pets_sync ON pets (is_synced, is_deleted)');
        await db.execute('CREATE INDEX idx_health_records_sync ON health_records (is_synced, is_deleted)');
        await db.execute('CREATE INDEX idx_weight_entries_sync ON weight_entries (is_synced, is_deleted)');
        await db.execute('CREATE INDEX idx_care_plans_sync ON care_plans (is_synced, is_deleted)');
        await db.execute('CREATE INDEX idx_sync_queue_timestamp ON sync_queue (timestamp)');
      },
    );
  }

  // Check network connectivity
  Future<void> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _hasNetworkConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _hasNetworkConnection = false;
    }
  }

  // Start periodic sync every 5 minutes when app is active
  Future<void> _startPeriodicSync() async {
    // Note: In a real app, you'd use a timer or background fetch
    // For this implementation, we'll trigger sync manually
  }

  // Manual sync trigger
  Future<SyncResult> syncData() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _isSyncing = true;
    
    try {
      await _checkNetworkConnection();
      
      if (!_hasNetworkConnection) {
        return SyncResult(success: false, message: 'No network connection');
      }

      // Get user token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return SyncResult(success: false, message: 'User not authenticated');
      }

      // Perform bidirectional sync
      final uploadResult = await _uploadPendingChanges(token);
      if (!uploadResult.success) {
        return uploadResult;
      }

      final downloadResult = await _downloadServerChanges(token);
      if (!downloadResult.success) {
        return downloadResult;
      }

      return SyncResult(success: true, message: 'Sync completed successfully');
    } catch (e) {
      return SyncResult(success: false, message: 'Sync failed: ${e.toString()}');
    } finally {
      _isSyncing = false;
    }
  }

  // Upload pending changes to server
  Future<SyncResult> _uploadPendingChanges(String token) async {
    final db = _database!;
    
    // Get all unsynced entities
    final pets = await db.query('pets', where: 'is_synced = ? AND is_deleted = ?', whereArgs: [0, 0]);
    final healthRecords = await db.query('health_records', where: 'is_synced = ? AND is_deleted = ?', whereArgs: [0, 0]);
    final weightEntries = await db.query('weight_entries', where: 'is_synced = ? AND is_deleted = ?', whereArgs: [0, 0]);
    final carePlans = await db.query('care_plans', where: 'is_synced = ? AND is_deleted = ?', whereArgs: [0, 0]);

    // Upload pets
    for (final petData in pets) {
      try {
        final pet = Pet.fromJson(petData);
        final response = await _apiClient.post('/api/pets', pet.toJson());
        
        if (response['success'] == true) {
          await db.update(
            'pets',
            {
              'is_synced': 1,
              'last_sync_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [pet.id],
          );
        }
      } catch (e) {
        // Add to sync queue for retry
        await _addToSyncQueue('pet', petData['id'] as String, 'create', petData);
      }
    }

    // Upload health records
    for (final recordData in healthRecords) {
      try {
        final record = HealthRecord.fromJson(recordData);
        final response = await _apiClient.post('/api/pets/${record.petId}/health-records', record.toJson());
        
        if (response['success'] == true) {
          await db.update(
            'health_records',
            {
              'is_synced': 1,
              'last_sync_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [record.id],
          );
        }
      } catch (e) {
        await _addToSyncQueue('health_record', recordData['id'] as String, 'create', recordData);
      }
    }

    // Upload weight entries
    for (final weightData in weightEntries) {
      try {
        final weight = WeightEntry.fromJson(weightData);
        final response = await _apiClient.post('/api/pets/${weight.petId}/weight-entries', weight.toJson());
        
        if (response['success'] == true) {
          await db.update(
            'weight_entries',
            {
              'is_synced': 1,
              'last_sync_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [weight.id],
          );
        }
      } catch (e) {
        await _addToSyncQueue('weight_entry', weightData['id'] as String, 'create', weightData);
      }
    }

    // Upload care plans
    for (final planData in carePlans) {
      try {
        final plan = CarePlan.fromJson(planData);
        final response = await _apiClient.post('/api/pets/${plan.petId}/care-plans', plan.toJson());
        
        if (response['success'] == true) {
          await db.update(
            'care_plans',
            {
              'is_synced': 1,
              'last_sync_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [plan.id],
          );
        }
      } catch (e) {
        await _addToSyncQueue('care_plan', planData['id'] as String, 'create', planData);
      }
    }

    return SyncResult(success: true, message: 'Upload completed');
  }

  // Download changes from server
  Future<SyncResult> _downloadServerChanges(String token) async {
    try {
      // Get last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTimestamp = prefs.getString('last_sync_timestamp') ?? '1970-01-01T00:00:00.000Z';

      // Download updated pets
      final petsResponse = await _apiClient.get('/api/pets?updated_since=$lastSyncTimestamp');
      if (petsResponse['success'] == true && petsResponse['data'] != null) {
        for (final petData in petsResponse['data']) {
          await _savePetLocally(petData);
        }
      }

      // Download updated health records
      final healthResponse = await _apiClient.get('/api/health-records?updated_since=$lastSyncTimestamp');
      if (healthResponse['success'] == true && healthResponse['data'] != null) {
        for (final recordData in healthResponse['data']) {
          await _saveHealthRecordLocally(recordData);
        }
      }

      // Download updated weight entries
      final weightResponse = await _apiClient.get('/api/weight-entries?updated_since=$lastSyncTimestamp');
      if (weightResponse['success'] == true && weightResponse['data'] != null) {
        for (final weightData in weightResponse['data']) {
          await _saveWeightEntryLocally(weightData);
        }
      }

      // Download updated care plans
      final carePlanResponse = await _apiClient.get('/api/care-plans?updated_since=$lastSyncTimestamp');
      if (carePlanResponse['success'] == true && carePlanResponse['data'] != null) {
        for (final planData in carePlanResponse['data']) {
          await _saveCarePlanLocally(planData);
        }
      }

      // Update last sync timestamp
      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());

      return SyncResult(success: true, message: 'Download completed');
    } catch (e) {
      return SyncResult(success: false, message: 'Download failed: ${e.toString()}');
    }
  }

  // Save pet locally
  Future<void> _savePetLocally(Map<String, dynamic> petData) async {
    final db = _database!;
    final pet = Pet.fromJson(petData);
    
    await db.insert(
      'pets',
      {
        ...pet.toJson(),
        'is_synced': 1,
        'last_sync_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save health record locally
  Future<void> _saveHealthRecordLocally(Map<String, dynamic> recordData) async {
    final db = _database!;
    final record = HealthRecord.fromJson(recordData);
    
    await db.insert(
      'health_records',
      {
        ...record.toJson(),
        'is_synced': 1,
        'last_sync_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save weight entry locally
  Future<void> _saveWeightEntryLocally(Map<String, dynamic> weightData) async {
    final db = _database!;
    final weight = WeightEntry.fromJson(weightData);
    
    await db.insert(
      'weight_entries',
      {
        ...weight.toJson(),
        'is_synced': 1,
        'last_sync_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save care plan locally
  Future<void> _saveCarePlanLocally(Map<String, dynamic> planData) async {
    final db = _database!;
    final plan = CarePlan.fromJson(planData);
    
    await db.insert(
      'care_plans',
      {
        ...plan.toJson(),
        'is_synced': 1,
        'last_sync_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add operation to sync queue for retry
  Future<void> _addToSyncQueue(String entityType, String entityId, String operation, Map<String, dynamic> data) async {
    final db = _database!;
    
    await db.insert(
      'sync_queue',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Process sync queue (retry failed operations)
  Future<void> processSyncQueue() async {
    final db = _database!;
    final queueItems = await db.query(
      'sync_queue',
      where: 'retry_count < ?',
      whereArgs: [3], // Max retry count
      orderBy: 'timestamp ASC',
    );

    for (final item in queueItems) {
      try {
        final entityType = item['entity_type'] as String;
        final entityId = item['entity_id'] as String;
        final operation = item['operation'] as String;
        final data = jsonDecode(item['data'] as String);

        bool success = false;

        switch (entityType) {
          case 'pet':
            success = await _retryPetOperation(operation, data);
            break;
          case 'health_record':
            success = await _retryHealthRecordOperation(operation, data);
            break;
          case 'weight_entry':
            success = await _retryWeightEntryOperation(operation, data);
            break;
          case 'care_plan':
            success = await _retryCarePlanOperation(operation, data);
            break;
        }

        if (success) {
          // Remove from queue if successful
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
        } else {
          // Increment retry count
          await db.update(
            'sync_queue',
            {'retry_count': (item['retry_count'] as int) + 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      } catch (e) {
        // Increment retry count on error
        await db.update(
          'sync_queue',
          {'retry_count': (item['retry_count'] as int) + 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    // Clean up old queue items (older than 7 days with max retries)
    final weekAgo = DateTime.now().subtract(Duration(days: 7)).toIso8601String();
    await db.delete(
      'sync_queue',
      where: 'timestamp < ? AND retry_count >= ?',
      whereArgs: [weekAgo, 3],
    );
  }

  // Retry pet operation
  Future<bool> _retryPetOperation(String operation, Map<String, dynamic> data) async {
    try {
      if (operation == 'create') {
        final response = await _apiClient.post('/api/pets', data);
        return response['success'] == true;
      } else if (operation == 'update') {
        final response = await _apiClient.put('/api/pets/${data['id']}', data);
        return response['success'] == true;
      } else if (operation == 'delete') {
        final response = await _apiClient.delete('/api/pets/${data['id']}');
        return response['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry health record operation
  Future<bool> _retryHealthRecordOperation(String operation, Map<String, dynamic> data) async {
    try {
      if (operation == 'create') {
        final response = await _apiClient.post('/api/pets/${data['pet_id']}/health-records', data);
        return response['success'] == true;
      } else if (operation == 'update') {
        final response = await _apiClient.put('/api/health-records/${data['id']}', data);
        return response['success'] == true;
      } else if (operation == 'delete') {
        final response = await _apiClient.delete('/api/health-records/${data['id']}');
        return response['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry weight entry operation
  Future<bool> _retryWeightEntryOperation(String operation, Map<String, dynamic> data) async {
    try {
      if (operation == 'create') {
        final response = await _apiClient.post('/api/pets/${data['pet_id']}/weight-entries', data);
        return response['success'] == true;
      } else if (operation == 'update') {
        final response = await _apiClient.put('/api/weight-entries/${data['id']}', data);
        return response['success'] == true;
      } else if (operation == 'delete') {
        final response = await _apiClient.delete('/api/weight-entries/${data['id']}');
        return response['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry care plan operation
  Future<bool> _retryCarePlanOperation(String operation, Map<String, dynamic> data) async {
    try {
      if (operation == 'create') {
        final response = await _apiClient.post('/api/pets/${data['pet_id']}/care-plans', data);
        return response['success'] == true;
      } else if (operation == 'update') {
        final response = await _apiClient.put('/api/care-plans/${data['id']}', data);
        return response['success'] == true;
      } else if (operation == 'delete') {
        final response = await _apiClient.delete('/api/care-plans/${data['id']}');
        return response['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final db = _database!;
    
    final pendingPets = await db.rawQuery('SELECT COUNT(*) as count FROM pets WHERE is_synced = 0 AND is_deleted = 0');
    final pendingHealth = await db.rawQuery('SELECT COUNT(*) as count FROM health_records WHERE is_synced = 0 AND is_deleted = 0');
    final pendingWeight = await db.rawQuery('SELECT COUNT(*) as count FROM weight_entries WHERE is_synced = 0 AND is_deleted = 0');
    final pendingCarePlans = await db.rawQuery('SELECT COUNT(*) as count FROM care_plans WHERE is_synced = 0 AND is_deleted = 0');
    final queueCount = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');

    final totalPending = (pendingPets[0]['count'] as int) +
                        (pendingHealth[0]['count'] as int) +
                        (pendingWeight[0]['count'] as int) +
                        (pendingCarePlans[0]['count'] as int) +
                        (queueCount[0]['count'] as int);

    return SyncStatus(
      isSyncing: _isSyncing,
      hasNetworkConnection: _hasNetworkConnection,
      pendingChanges: totalPending,
      lastSyncTime: DateTime.now(), // In a real app, store and retrieve actual last sync time
    );
  }

  // Clear all local data (for logout)
  Future<void> clearLocalData() async {
    final db = _database!;
    await db.delete('pets');
    await db.delete('health_records');
    await db.delete('weight_entries');
    await db.delete('care_plans');
    await db.delete('sync_queue');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_timestamp');
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int? syncedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount,
  });
}

class SyncStatus {
  final bool isSyncing;
  final bool hasNetworkConnection;
  final int pendingChanges;
  final DateTime? lastSyncTime;

  SyncStatus({
    required this.isSyncing,
    required this.hasNetworkConnection,
    required this.pendingChanges,
    this.lastSyncTime,
  });
}