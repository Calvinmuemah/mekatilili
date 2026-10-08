const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');
const { pool } = require('../config/db');

async function seedDatabase() {
  const client = await pool.connect();
  try {
    console.log('--- Starting Database Seeding ---');
    await client.query('BEGIN');

    // 1. Seed Admins
    console.log('Seeding Admins...');
    const isProduction = process.env.NODE_ENV === 'production';
    const adminPassword = process.env.ADMIN_INITIAL_PASSWORD || (isProduction ? null : 'AdminPass123!');
    const editorPassword = process.env.EDITOR_INITIAL_PASSWORD || (isProduction ? null : 'EditorPass123!');

    if (!adminPassword) {
      console.warn('⚠️  PRODUCTION WARNING: ADMIN_INITIAL_PASSWORD not set in environment. Skipping default admin seeding for security.');
    } else {
      const superAdminHash = await bcrypt.hash(adminPassword, 10);
      const editorHash = editorPassword ? await bcrypt.hash(editorPassword, 10) : superAdminHash;

      await client.query(`
        INSERT INTO admins (email, password_hash, name, role)
        VALUES 
          ('admin@mekatilili.org', $1, 'Lead Administrator', 'SUPER_ADMIN'),
          ('editor@mekatilili.org', $2, 'Historical Content Editor', 'CONTENT_EDITOR')
        ON CONFLICT (email) DO NOTHING;
      `, [superAdminHash, editorHash]);
    }

    // 2. Seed Chapter 1 from Godot JSON
    console.log('Seeding Chapter 1...');
    const ch1Path = path.join(__dirname, '../../../game/data/chapters/chapter_1.json');
    let ch1 = {
      id: "chapter_1",
      number: 1,
      title: "Whispers in the Palms",
      subtitle: "The village of Ulungu wakes to colonial unrest",
      description: "In 1913 coastal Kenya, the Giriama homeland faces escalating pressure.",
      historical_note: "British Assistant District Commissioner Arthur Champion entered Giriama territory.",
      scene: "res://scenes/environments/VillageLevel.tscn"
    };
    if (fs.existsSync(ch1Path)) {
      ch1 = JSON.parse(fs.readFileSync(ch1Path, 'utf8'));
    }

    await client.query(`
      INSERT INTO chapters (id, chapter_number, title, subtitle, description, summary, historical_note, scene_path, status, order_index)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'PUBLISHED', 1)
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        subtitle = EXCLUDED.subtitle,
        description = EXCLUDED.description,
        historical_note = EXCLUDED.historical_note,
        status = 'PUBLISHED';
    `, [
      ch1.id,
      ch1.number || 1,
      ch1.title,
      ch1.subtitle || '',
      ch1.description || '',
      ch1.summary || ch1.description || '',
      ch1.historical_note || '',
      ch1.scene || 'res://scenes/environments/VillageLevel.tscn'
    ]);

    // 3. Seed NPCs
    console.log('Seeding NPCs...');
    const npcs = [
      {
        id: "npc_nyevu",
        name: "Villager Nyevu",
        description: "A concerned Giriama mother and farmer residing in Ulungu.",
        role: "Villager / Farmer",
        portrait_url: "res://assets/characters/portraits/nyevu.png",
        chapter_id: ch1.id,
        location_name: "Southern Ulungu Homestead"
      },
      {
        id: "npc_charo",
        name: "Warrior Charo",
        description: "A spirited young Giriama warrior eager to defend his community.",
        role: "Warrior / Scout",
        portrait_url: "res://assets/characters/portraits/charo.png",
        chapter_id: ch1.id,
        location_name: "Village Crossroads"
      },
      {
        id: "npc_mzee_fondo",
        name: "Elder Mzee Fondo",
        description: "Revered elder of Ulungu and member of the council of Wazee.",
        role: "Village Council Elder",
        portrait_url: "res://assets/characters/portraits/mzee_fondo.png",
        chapter_id: ch1.id,
        location_name: "Council Baobab"
      },
      {
        id: "npc_wanje",
        name: "Wanje wa Mwadorikola",
        description: "Medicine man and elder of Kaya Fungo, trusted advisor to Mekatilili.",
        role: "Kaya Elder / Healer",
        portrait_url: "res://assets/characters/portraits/wanje.png",
        chapter_id: ch1.id,
        location_name: "Eastern Kaya Border"
      }
    ];

    for (const npc of npcs) {
      await client.query(`
        INSERT INTO npcs (id, name, description, role, portrait_url, chapter_id, location_name, is_active)
        VALUES ($1, $2, $3, $4, $5, $6, $7, TRUE)
        ON CONFLICT (id) DO UPDATE SET
          name = EXCLUDED.name,
          description = EXCLUDED.description,
          role = EXCLUDED.role,
          portrait_url = EXCLUDED.portrait_url;
      `, [npc.id, npc.name, npc.description, npc.role, npc.portrait_url, npc.chapter_id, npc.location_name]);
    }

    // 4. Seed Quests and Objectives
    console.log('Seeding Quests & Objectives...');
    const q1Path = path.join(__dirname, '../../../game/data/quests/quest_chapter_1.json');
    let q1 = {
      id: "quest_chapter_1",
      title: "Echoes of the Homeland",
      description: "Colonial messengers have posted demands across the territory.",
      reward_text: "The people of Ulungu are united. Community support reached 100%.",
      objectives: [
        { id: "talk_nyevu", description: "Speak with Villager Nyevu about the colonial tax notice." },
        { id: "inspect_crops", description: "Check the village Shamba and harvest cassava for the community." },
        { id: "consult_mzee_fondo", description: "Consult Elder Mzee Fondo at the Sacred Council Baobab." },
        { id: "find_wanje", description: "Seek out Wanje wa Mwadorikola near the Kaya boundary." },
        { id: "gather_community", description: "Address the village gathering at the council fire and pledge resistance." }
      ]
    };
    if (fs.existsSync(q1Path)) {
      q1 = JSON.parse(fs.readFileSync(q1Path, 'utf8'));
    }

    await client.query(`
      INSERT INTO quests (id, chapter_id, title, description, status, reward_text, order_index)
      VALUES ($1, $2, $3, $4, 'PUBLISHED', $5, 1)
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        description = EXCLUDED.description,
        status = 'PUBLISHED';
    `, [q1.id, ch1.id, q1.title, q1.description, q1.reward_text || '']);

    const objTypes = [
      'TALK_TO_NPC',
      'COLLECT_ITEM',
      'TALK_TO_NPC',
      'TALK_TO_NPC',
      'TRIGGER_EVENT'
    ];

    let order = 1;
    for (const obj of q1.objectives || []) {
      await client.query(`
        INSERT INTO quest_objectives (id, quest_id, title, description, objective_type, required, order_index)
        VALUES ($1, $2, $3, $4, $5, TRUE, $6)
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          description = EXCLUDED.description,
          order_index = EXCLUDED.order_index;
      `, [obj.id, q1.id, obj.description, obj.description, objTypes[order - 1] || 'CUSTOM', order]);
      order++;
    }

    // 5. Seed Dialogues from Godot JSON
    console.log('Seeding Dialogues...');
    const dialogueFiles = [
      { id: "dialogue_nyevu", npc_id: "npc_nyevu", file: "dialogue_nyevu.json" },
      { id: "dialogue_charo", npc_id: "npc_charo", file: "dialogue_charo.json" },
      { id: "dialogue_mzee_fondo", npc_id: "npc_mzee_fondo", file: "dialogue_mzee_fondo.json" },
      { id: "dialogue_wanje", npc_id: "npc_wanje", file: "dialogue_wanje.json" }
    ];

    for (const df of dialogueFiles) {
      const dPath = path.join(__dirname, '../../../game/data/dialogue', df.file);
      let dData = { title: df.id, nodes: {} };
      if (fs.existsSync(dPath)) {
        dData = JSON.parse(fs.readFileSync(dPath, 'utf8'));
      }

      await client.query(`
        INSERT INTO dialogues (id, npc_id, chapter_id, title, start_node_id, raw_nodes, status)
        VALUES ($1, $2, $3, $4, 'start', $5, 'PUBLISHED')
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          raw_nodes = EXCLUDED.raw_nodes,
          status = 'PUBLISHED';
      `, [df.id, df.npc_id, ch1.id, dData.title || df.id, JSON.stringify(dData.nodes || {})]);
    }

    // 6. Seed Collectibles from Godot JSON
    console.log('Seeding Collectibles...');
    const colPath = path.join(__dirname, '../../../game/data/collectibles/collectibles.json');
    let cols = [];
    if (fs.existsSync(colPath)) {
      cols = JSON.parse(fs.readFileSync(colPath, 'utf8'));
    }

    for (const c of cols) {
      await client.query(`
        INSERT INTO collectibles (id, name, description, category, image_url, historical_context, chapter_id, status)
        VALUES ($1, $2, $3, 'CULTURAL_ARTIFACT', $4, $5, $6, 'PUBLISHED')
        ON CONFLICT (id) DO UPDATE SET
          name = EXCLUDED.name,
          description = EXCLUDED.description,
          historical_context = EXCLUDED.historical_context;
      `, [c.id, c.name, c.description, c.icon || '', c.historical_note || '', ch1.id]);
    }

    // 7. Seed Historical References
    console.log('Seeding Historical References...');
    const histRefs = [
      {
        id: "ref_brantley_1981",
        title: "The Giriama and British Colonialism in Kenya: A Study in Resilience and Anti-Colonial Protest",
        description: "Primary scholarly authority on the 1913-1914 Giriama uprising, Mekatilili's role, and colonial reports.",
        source: "University of California Press",
        source_url: "https://www.ucpress.edu/",
        author: "Cynthia Brantley",
        publication_date: "1981",
        notes: "Detailed documentation of Arthur Champion's tour, the Kwa Junda confrontation, and Mekatilili's exile to Kisii."
      },
      {
        id: "ref_champion_journal",
        title: "The Agiryama of Kenya (Colonial District Commissioner Journals)",
        description: "Official colonial records and diaries kept by Assistant District Commissioner Arthur M. Champion during his stationing in coastal Kenya.",
        source: "Royal Anthropological Institute",
        source_url: "https://www.therai.org.uk/",
        author: "Arthur M. Champion",
        publication_date: "1967 (ed. John Middleton)",
        notes: "Records the administrative view, taxation orders, and unexpected unified resistance of the Giriama people."
      }
    ];

    for (const ref of histRefs) {
      await client.query(`
        INSERT INTO historical_references (id, title, description, source, source_url, author, publication_date, notes, related_chapter_id, is_verified)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, TRUE)
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          description = EXCLUDED.description,
          source = EXCLUDED.source,
          notes = EXCLUDED.notes;
      `, [ref.id, ref.title, ref.description, ref.source, ref.source_url, ref.author, ref.publication_date, ref.notes, ch1.id]);
    }

    // 8. Seed Journal Baseline
    console.log('Seeding Baseline Journal...');
    await client.query(`
      INSERT INTO journal_entries (id, title, content, category, chapter_id, status)
      VALUES 
        ('jrn_mekatilili_bio', 'Mekatilili wa Menza & The Agiriama', 'Mekatilili wa Menza was an elder, prophetess, and resistance leader of the Giriama people who unified the nine clans against British forced recruitment.', 'HISTORY', $1, 'PUBLISHED'),
        ('jrn_sacred_kayas', 'The Sacred Kayas', 'The Kayas are ancient fortified forest sanctuaries containing ancestral shrines and council grounds of the elders.', 'HISTORY', $1, 'PUBLISHED')
      ON CONFLICT (id) DO NOTHING;
    `, [ch1.id]);

    await client.query('COMMIT');
    console.log('--- Database Seeding Completed Successfully ---');
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    console.error('Seeding failed:', err);
    process.exit(1);
  } finally {
    client.release();
    if (require.main === module) {
      await pool.end();
    }
  }
}

if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
