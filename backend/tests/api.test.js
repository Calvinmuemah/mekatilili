const request = require('supertest');
const app = require('../src/app');
const { pool } = require('../src/config/db');

describe('Mekatilili Game Backend API Test Suite', () => {
  let playerToken = '';
  let adminToken = '';
  const testEmail = `player_${Date.now()}@test.com`;
  const testUsername = `player_${Date.now()}`;

  afterAll(async () => {
    await pool.end();
  });

  // 1. HEALTH ENDPOINT
  describe('GET /api/v1/health', () => {
    it('should return 200 with status ok', async () => {
      const res = await request(app).get('/api/v1/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.status).toBe('ok');
    });
  });

  // 2. PLAYER AUTHENTICATION
  describe('Player Authentication Endpoints', () => {
    it('should register a new player user successfully', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: testEmail,
          username: testUsername,
          password: 'Password123!',
          displayName: 'Mekatilili Player 1',
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe(testEmail.toLowerCase());
      expect(res.body.data.token).toBeDefined();
    });

    it('should reject registration with existing email', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: testEmail,
          username: 'unique_user_99',
          password: 'Password123!',
        });

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('EMAIL_EXISTS');
    });

    it('should login player and return JWT token', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          emailOrUsername: testEmail,
          password: 'Password123!',
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.token).toBeDefined();
      playerToken = res.body.data.token;
    });

    it('should retrieve player profile with valid token', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${playerToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.username).toBe(testUsername);
    });

    it('should reject unauthenticated request to /auth/me', async () => {
      const res = await request(app).get('/api/v1/auth/me');
      expect(res.statusCode).toBe(401);
    });
  });

  // 3. ADMIN AUTHENTICATION
  describe('Admin Authentication Endpoints', () => {
    it('should login seeded super admin successfully', async () => {
      const res = await request(app)
        .post('/api/v1/admin/auth/login')
        .send({
          email: 'admin@mekatilili.org',
          password: 'AdminPass123!',
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.admin.role).toBe('SUPER_ADMIN');
      expect(res.body.data.token).toBeDefined();
      adminToken = res.body.data.token;
    });

    it('should retrieve admin profile with valid admin token', async () => {
      const res = await request(app)
        .get('/api/v1/admin/auth/me')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.admin.email).toBe('admin@mekatilili.org');
    });

    it('should prevent player tokens from accessing admin routes', async () => {
      const res = await request(app)
        .get('/api/v1/admin/auth/me')
        .set('Authorization', `Bearer ${playerToken}`);

      expect(res.statusCode).toBe(403);
    });
  });

  // 4. CONTENT ENDPOINTS
  describe('Content Endpoints', () => {
    it('should fetch public published bundle for game client', async () => {
      const res = await request(app).get('/api/v1/content/bundle');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.chapters.length).toBeGreaterThanOrEqual(1);
      expect(res.body.data.quests.length).toBeGreaterThanOrEqual(1);
      expect(res.body.data.npcs.length).toBeGreaterThanOrEqual(4);
      expect(res.body.data.collectibles.length).toBeGreaterThanOrEqual(3);
    });

    it('should fetch public published chapters', async () => {
      const res = await request(app).get('/api/v1/content/chapters');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('should allow admin to create and update a draft chapter', async () => {
      const tempId = `ch_test_${Date.now()}`;
      const createRes = await request(app)
        .post('/api/v1/admin/content/chapters')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          id: tempId,
          chapterNumber: 99,
          title: 'Test Chapter',
          subtitle: 'A testing subtitle',
          status: 'DRAFT',
        });

      expect(createRes.statusCode).toBe(201);
      expect(createRes.body.data.id).toBe(tempId);

      const updateRes = await request(app)
        .put(`/api/v1/admin/content/chapters/${tempId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Updated Test Chapter',
          status: 'PUBLISHED',
        });

      expect(updateRes.statusCode).toBe(200);
      expect(updateRes.body.data.title).toBe('Updated Test Chapter');

      // Clean up
      await request(app)
        .delete(`/api/v1/admin/content/chapters/${tempId}`)
        .set('Authorization', `Bearer ${adminToken}`);
    });
  });

  // 5. LOCAL-FIRST CLOUD SAVE / PLAYER PROGRESS
  describe('Player Progress & Sync Endpoints', () => {
    it('should synchronize player progress payload from game', async () => {
      const syncData = {
        chapter: 1,
        scene: 'res://scenes/environments/VillageLevel.tscn',
        progressPercentage: 60,
        communityUnity: 45,
        playerPosition: { x: 500, y: 620 },
        collectibles: ['calabash_palm', 'kaya_herbs'],
        storyFlags: {
          nyevu_reassured: true,
          fondo_agreed: true,
        },
      };

      const res = await request(app)
        .post('/api/v1/player/sync')
        .set('Authorization', `Bearer ${playerToken}`)
        .send(syncData);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.progress.current_chapter).toBe(1);
      expect(res.body.data.progress.community_unity).toBe(45);
      expect(res.body.data.collectibles).toContain('calabash_palm');
      expect(res.body.data.storyFlags.nyevu_reassured).toBe(true);
    });

    it('should retrieve synced progress for player', async () => {
      const res = await request(app)
        .get('/api/v1/player/progress')
        .set('Authorization', `Bearer ${playerToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.progress.community_unity).toBe(45);
    });
  });

  // 6. ANALYTICS ENDPOINTS
  describe('Analytics Endpoints', () => {
    it('should ingest gameplay event', async () => {
      const res = await request(app)
        .post('/api/v1/analytics/event')
        .set('Authorization', `Bearer ${playerToken}`)
        .send({
          eventType: 'CHAPTER_STARTED',
          chapterId: 'chapter_1',
          metadata: { initial_support: 0 },
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.event_type).toBe('CHAPTER_STARTED');
    });

    it('should fetch analytics dashboard metrics for admin', async () => {
      const res = await request(app)
        .get('/api/v1/analytics/dashboard')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.publishedChapters).toBeGreaterThanOrEqual(1);
      expect(res.body.data.activeNPCs).toBeGreaterThanOrEqual(4);
    });
  });
});
