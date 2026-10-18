import os
import json
import urllib.request
import urllib.error

DB_URL = os.environ.get(
    'DATABASE_URL',
    'postgresql://neondb_owner:npg_uyzArpUD48qc@ep-spring-hall-b5cs0rej-pooler.c-7.us-east-2.aws.neon.tech/neondb?sslmode=require'
)
SQL_ENDPOINT = 'https://ep-spring-hall-b5cs0rej-pooler.c-7.us-east-2.aws.neon.tech/sql'

# Bcrypt hashes for AdminPass123! and EditorPass123!
SUPER_ADMIN_HASH = '$2b$10$p4tKvv1Mo32RN7Z1ocK60.lbwektk9bH/nPgfbGMvQproi2RVUuyO'
EDITOR_HASH = '$2b$10$ObgVKCnChGExwTMmng7XGuC9/eeqPA/l6.7fhB772UBOFQl/kpj9K'

def run_query(stmt):
    stmt = stmt.strip()
    if not stmt:
        return None
    headers = {
        'Neon-Connection-String': DB_URL,
        'Content-Type': 'application/json'
    }
    data = json.dumps({'query': stmt}).encode('utf-8')
    req = urllib.request.Request(SQL_ENDPOINT, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')
        print(f"SQL Error ({e.code}) on statement: {stmt[:60]}...")
        print("Details:", body)
        raise

def escape_sql(text):
    if text is None:
        return 'NULL'
    return "'" + str(text).replace("'", "''") + "'"

def main():
    print("=== 1. INITIALIZING MIGRATIONS TRACKING ===")
    run_query('''
        CREATE TABLE IF NOT EXISTS schema_migrations (
            id SERIAL PRIMARY KEY,
            migration_name VARCHAR(255) UNIQUE NOT NULL,
            applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        );
    ''')
    print("✓ schema_migrations table ready")

    backend_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    if os.path.basename(backend_dir) == 'backend':
        base_dir = os.path.dirname(backend_dir)
    else:
        base_dir = backend_dir
        backend_dir = os.path.join(base_dir, 'backend')
    migrations_dir = os.path.join(backend_dir, 'database', 'migrations')
    migration_files = sorted([f for f in os.listdir(migrations_dir) if f.endswith('.sql')])

    print(f"\n=== 2. APPLYING {len(migration_files)} MIGRATIONS ===")
    for f in migration_files:
        check = run_query(f"SELECT migration_name FROM schema_migrations WHERE migration_name = '{f}';")
        if check and len(check.get('rows', [])) > 0:
            print(f"- Skipping {f} (already applied)")
            continue

        print(f"Applying {f}...")
        with open(os.path.join(migrations_dir, f), 'r', encoding='utf-8') as fp:
            content = fp.read()

        # Split statements by semicolon while ignoring comments
        statements = [s.strip() for s in content.split(';') if s.strip()]
        for s in statements:
            run_query(s)

        run_query(f"INSERT INTO schema_migrations (migration_name) VALUES ('{f}');")
        print(f"✓ Applied {f}")

    print("\n=== 3. SEEDING DATABASE ===")

    # 1. Admins
    print("Seeding admins...")
    run_query(f"""
        INSERT INTO admins (email, password_hash, name, role)
        VALUES 
            ('admin@mekatilili.org', {escape_sql(SUPER_ADMIN_HASH)}, 'Lead Administrator', 'SUPER_ADMIN'),
            ('editor@mekatilili.org', {escape_sql(EDITOR_HASH)}, 'Historical Content Editor', 'CONTENT_EDITOR')
        ON CONFLICT (email) DO UPDATE SET
            password_hash = EXCLUDED.password_hash,
            name = EXCLUDED.name,
            role = EXCLUDED.role;
    """)
    print("✓ Admins seeded (admin@mekatilili.org / AdminPass123!)")

    # 2. Chapter 1
    print("Seeding Chapter 1...")
    ch1_file = os.path.join(base_dir, 'game', 'data', 'chapters', 'chapter_1.json')
    ch1 = {
        "id": "chapter_1",
        "number": 1,
        "title": "Whispers in the Palms",
        "subtitle": "The village of Ulungu wakes to colonial unrest",
        "description": "In 1913 coastal Kenya, the Giriama homeland faces escalating pressure.",
        "historical_note": "British Assistant District Commissioner Arthur Champion entered Giriama territory.",
        "scene": "res://scenes/environments/VillageLevel.tscn"
    }
    if os.path.exists(ch1_file):
        with open(ch1_file, 'r', encoding='utf-8') as fp:
            ch1 = json.load(fp)

    run_query(f"""
        INSERT INTO chapters (id, chapter_number, title, subtitle, description, summary, historical_note, scene_path, status, order_index)
        VALUES (
            {escape_sql(ch1['id'])},
            {ch1.get('number', 1)},
            {escape_sql(ch1['title'])},
            {escape_sql(ch1.get('subtitle', ''))},
            {escape_sql(ch1.get('description', ''))},
            {escape_sql(ch1.get('summary', ch1.get('description', '')))},
            {escape_sql(ch1.get('historical_note', ''))},
            {escape_sql(ch1.get('scene', 'res://scenes/environments/VillageLevel.tscn'))},
            'PUBLISHED',
            1
        )
        ON CONFLICT (id) DO UPDATE SET
            title = EXCLUDED.title,
            subtitle = EXCLUDED.subtitle,
            description = EXCLUDED.description,
            historical_note = EXCLUDED.historical_note,
            status = 'PUBLISHED';
    """)
    print("✓ Chapter 1 seeded")

    # 3. NPCs
    print("Seeding NPCs...")
    npcs = [
        {
            "id": "npc_nyevu",
            "name": "Villager Nyevu",
            "description": "A concerned Giriama mother and farmer residing in Ulungu.",
            "role": "Villager / Farmer",
            "portrait_url": "res://assets/characters/portraits/nyevu.png",
            "chapter_id": ch1['id'],
            "location_name": "Southern Ulungu Homestead"
        },
        {
            "id": "npc_charo",
            "name": "Warrior Charo",
            "description": "A spirited young Giriama warrior eager to defend his community.",
            "role": "Warrior / Scout",
            "portrait_url": "res://assets/characters/portraits/charo.png",
            "chapter_id": ch1['id'],
            "location_name": "Village Crossroads"
        },
        {
            "id": "npc_mzee_fondo",
            "name": "Elder Mzee Fondo",
            "description": "Revered elder of Ulungu and member of the council of Wazee.",
            "role": "Village Council Elder",
            "portrait_url": "res://assets/characters/portraits/mzee_fondo.png",
            "chapter_id": ch1['id'],
            "location_name": "Council Baobab"
        },
        {
            "id": "npc_wanje",
            "name": "Wanje wa Mwadorikola",
            "description": "Medicine man and elder of Kaya Fungo, trusted advisor to Mekatilili.",
            "role": "Kaya Elder / Healer",
            "portrait_url": "res://assets/characters/portraits/wanje.png",
            "chapter_id": ch1['id'],
            "location_name": "Eastern Kaya Border"
        }
    ]
    for npc in npcs:
        run_query(f"""
            INSERT INTO npcs (id, name, description, role, portrait_url, chapter_id, location_name, is_active)
            VALUES (
                {escape_sql(npc['id'])},
                {escape_sql(npc['name'])},
                {escape_sql(npc['description'])},
                {escape_sql(npc['role'])},
                {escape_sql(npc['portrait_url'])},
                {escape_sql(npc['chapter_id'])},
                {escape_sql(npc['location_name'])},
                TRUE
            )
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                description = EXCLUDED.description,
                role = EXCLUDED.role,
                portrait_url = EXCLUDED.portrait_url;
        """)
    print(f"✓ {len(npcs)} NPCs seeded")

    # 4. Quests & Objectives
    print("Seeding Quests & Objectives...")
    q1_file = os.path.join(base_dir, 'game', 'data', 'quests', 'quest_chapter_1.json')
    q1 = {
        "id": "quest_chapter_1",
        "title": "Echoes of the Homeland",
        "description": "Colonial messengers have posted demands across the territory.",
        "reward_text": "The people of Ulungu are united. Community support reached 100%.",
        "objectives": [
            { "id": "talk_nyevu", "description": "Speak with Villager Nyevu about the colonial tax notice." },
            { "id": "inspect_crops", "description": "Check the village Shamba and harvest cassava for the community." },
            { "id": "consult_mzee_fondo", "description": "Consult Elder Mzee Fondo at the Sacred Council Baobab." },
            { "id": "find_wanje", "description": "Seek out Wanje wa Mwadorikola near the Kaya boundary." },
            { "id": "gather_community", "description": "Address the village gathering at the council fire and pledge resistance." }
        ]
    }
    if os.path.exists(q1_file):
        with open(q1_file, 'r', encoding='utf-8') as fp:
            q1 = json.load(fp)

    run_query(f"""
        INSERT INTO quests (id, chapter_id, title, description, status, reward_text, order_index)
        VALUES (
            {escape_sql(q1['id'])},
            {escape_sql(ch1['id'])},
            {escape_sql(q1['title'])},
            {escape_sql(q1['description'])},
            'PUBLISHED',
            {escape_sql(q1.get('reward_text', ''))},
            1
        )
        ON CONFLICT (id) DO UPDATE SET
            title = EXCLUDED.title,
            description = EXCLUDED.description,
            status = 'PUBLISHED';
    """)

    obj_types = ['TALK_TO_NPC', 'COLLECT_ITEM', 'TALK_TO_NPC', 'TALK_TO_NPC', 'TRIGGER_EVENT']
    for idx, obj in enumerate(q1.get('objectives', []), 1):
        otype = obj_types[idx - 1] if idx - 1 < len(obj_types) else 'CUSTOM'
        run_query(f"""
            INSERT INTO quest_objectives (id, quest_id, title, description, objective_type, required, order_index)
            VALUES (
                {escape_sql(obj['id'])},
                {escape_sql(q1['id'])},
                {escape_sql(obj['description'])},
                {escape_sql(obj['description'])},
                {escape_sql(otype)},
                TRUE,
                {idx}
            )
            ON CONFLICT (id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                order_index = EXCLUDED.order_index;
        """)
    print("✓ Quests and objectives seeded")

    # 5. Dialogues
    print("Seeding Dialogues...")
    dialogue_files = [
        {"id": "dialogue_nyevu", "npc_id": "npc_nyevu", "file": "dialogue_nyevu.json"},
        {"id": "dialogue_charo", "npc_id": "npc_charo", "file": "dialogue_charo.json"},
        {"id": "dialogue_mzee_fondo", "npc_id": "npc_mzee_fondo", "file": "dialogue_mzee_fondo.json"},
        {"id": "dialogue_wanje", "npc_id": "npc_wanje", "file": "dialogue_wanje.json"}
    ]
    for df in dialogue_files:
        d_path = os.path.join(base_dir, 'game', 'data', 'dialogue', df['file'])
        d_data = {"title": df['id'], "nodes": {}}
        if os.path.exists(d_path):
            with open(d_path, 'r', encoding='utf-8') as fp:
                d_data = json.load(fp)

        raw_nodes_json = json.dumps(d_data.get('nodes', {}))
        run_query(f"""
            INSERT INTO dialogues (id, npc_id, chapter_id, title, start_node_id, raw_nodes, status)
            VALUES (
                {escape_sql(df['id'])},
                {escape_sql(df['npc_id'])},
                {escape_sql(ch1['id'])},
                {escape_sql(d_data.get('title', df['id']))},
                'start',
                {escape_sql(raw_nodes_json)},
                'PUBLISHED'
            )
            ON CONFLICT (id) DO UPDATE SET
                title = EXCLUDED.title,
                raw_nodes = EXCLUDED.raw_nodes,
                status = 'PUBLISHED';
        """)
    print(f"✓ {len(dialogue_files)} dialogues seeded")

    # 6. Collectibles
    print("Seeding Collectibles...")
    col_path = os.path.join(base_dir, 'game', 'data', 'collectibles', 'collectibles.json')
    cols = []
    if os.path.exists(col_path):
        with open(col_path, 'r', encoding='utf-8') as fp:
            cols = json.load(fp)

    for c in cols:
        run_query(f"""
            INSERT INTO collectibles (id, name, description, category, image_url, historical_context, chapter_id, status)
            VALUES (
                {escape_sql(c['id'])},
                {escape_sql(c['name'])},
                {escape_sql(c['description'])},
                'CULTURAL_ARTIFACT',
                {escape_sql(c.get('icon', ''))},
                {escape_sql(c.get('historical_note', ''))},
                {escape_sql(ch1['id'])},
                'PUBLISHED'
            )
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                description = EXCLUDED.description,
                historical_context = EXCLUDED.historical_context;
        """)
    print(f"✓ {len(cols)} collectibles seeded")

    # 7. Historical References
    print("Seeding Historical References...")
    hist_refs = [
        {
            "id": "ref_brantley_1981",
            "title": "The Giriama and British Colonialism in Kenya: A Study in Resilience and Anti-Colonial Protest",
            "description": "Primary scholarly authority on the 1913-1914 Giriama uprising, Mekatilili's role, and colonial reports.",
            "source": "University of California Press",
            "source_url": "https://www.ucpress.edu/",
            "author": "Cynthia Brantley",
            "publication_date": "1981",
            "notes": "Detailed documentation of Arthur Champion's tour, the Kwa Junda confrontation, and Mekatilili's exile to Kisii."
        },
        {
            "id": "ref_champion_journal",
            "title": "The Agiryama of Kenya (Colonial District Commissioner Journals)",
            "description": "Official colonial records and diaries kept by Assistant District Commissioner Arthur M. Champion during his stationing in coastal Kenya.",
            "source": "Royal Anthropological Institute",
            "source_url": "https://www.therai.org.uk/",
            "author": "Arthur M. Champion",
            "publication_date": "1967 (ed. John Middleton)",
            "notes": "Records the administrative view, taxation orders, and unexpected unified resistance of the Giriama people."
        }
    ]
    for ref in hist_refs:
        run_query(f"""
            INSERT INTO historical_references (id, title, description, source, source_url, author, publication_date, notes, related_chapter_id, is_verified)
            VALUES (
                {escape_sql(ref['id'])},
                {escape_sql(ref['title'])},
                {escape_sql(ref['description'])},
                {escape_sql(ref['source'])},
                {escape_sql(ref['source_url'])},
                {escape_sql(ref['author'])},
                {escape_sql(ref['publication_date'])},
                {escape_sql(ref['notes'])},
                {escape_sql(ch1['id'])},
                TRUE
            )
            ON CONFLICT (id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                source = EXCLUDED.source,
                notes = EXCLUDED.notes;
        """)
    print(f"✓ {len(hist_refs)} historical references seeded")

    # 8. Baseline Journal
    print("Seeding Baseline Journal...")
    run_query(f"""
        INSERT INTO journal_entries (id, title, content, category, chapter_id, status)
        VALUES 
            ('jrn_mekatilili_bio', 'Mekatilili wa Menza & The Agiriama', 'Mekatilili wa Menza was an elder, prophetess, and resistance leader of the Giriama people who unified the nine clans against British forced recruitment.', 'HISTORY', {escape_sql(ch1['id'])}, 'PUBLISHED'),
            ('jrn_sacred_kayas', 'The Sacred Kayas', 'The Kayas are ancient fortified forest sanctuaries containing ancestral shrines and council grounds of the elders.', 'HISTORY', {escape_sql(ch1['id'])}, 'PUBLISHED')
        ON CONFLICT (id) DO NOTHING;
    """)
    print("✓ Journal entries seeded")

    # 9. Verification
    print("\n=== 4. VERIFYING DATABASE TABLES & COUNTS ===")
    tables = [
        'admins', 'users', 'chapters', 'quests', 'quest_objectives',
        'npcs', 'dialogues', 'collectibles', 'journal_entries', 'historical_references'
    ]
    for t in tables:
        count_res = run_query(f"SELECT COUNT(*) as count FROM {t};")
        count = count_res['rows'][0]['count'] if count_res and count_res.get('rows') else '0'
        print(f"  • Table '{t}': {count} rows")

    print("\n✓ Database migration and seeding completed successfully!")

if __name__ == '__main__':
    main()
