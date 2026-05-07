# SQLite Migration & Performance Optimization TODO

## Phase 1: DatabaseService (New)
- [x] 1.1 Created lib/services/database_service.dart with UPSERTs, pagination, monthly SQL agg (minor compile fixes pending)

## Phase 2: StorageService Migration
- [ ] 2.1 Rewrite storage_service.dart → delegate to DatabaseService
- [ ] 2.2 Test persistence

## Phase 3: AppState Optimization
- [ ] 3.1 Integrate DatabaseService + caches
- [ ] 3.2 Migration in init()
- [ ] 3.3 Optimized methods

## Phase 4: UI Optimizations
- [ ] 4.1 Paginated transactions
- [ ] 4.2 RefreshIndicator

## Phase 5: Validation
- [ ] 5.1 Benchmarks, tests
- [ ] 5.2 ✅ COMPLETE
