import pandas as pd
import psycopg2


conn = psycopg2.connect(
    dbname ='fitbase', user='fituser',
    password ='fitbase123', host='localhost'
)
cur = conn.cursor()

df = pd.read_csv('assets/workouts.csv')
df['data'] = pd.to_datetime(df['data'])
df['observacao'] = df['observacao'].fillna('')
df['exercicio'] = df['exercicio'].str.strip().str.title()

print(f"CSV carregado: {len(df)} registros")
print(df.head())
print(df.columns.tolist())
# ---- INSERIR EXERCÍCIOS -----

exercicios = df[['exercicio', 'grupo_muscular']].drop_duplicates()

for _, row in exercicios.iterrows():
    cur.execute("""
        INSERT INTO exercicios (nome, grupo_muscular)
        VALUES (%s, %s)
        ON CONFLICT (nome) DO NOTHING
    """, (row['exercicio'], row['grupo_muscular']))


conn.commit()
print(f"✅ {len(exercicios)} exercícios inseridos!")    

# ---- INSERIR TREINOS ----

treinos = df[['data', 'duracao_min','observacao']].drop_duplicates(subset='data')


for _, row in treinos.iterrows():
    cur.execute("""
        INSERT INTO treinos (data, duracao_min, observacao)
        VALUES (%s, %s, %s)
        ON CONFLICT (data) DO NOTHING
        """, (row['data'], row['duracao_min'], row['observacao']))

conn.commit()
print(f"✅ {len(treinos)} treinos inseridos!")    

# ---- INSERIRI SÉRIES ------------
# BUSCA OS IDS do banco para fazer o relacionamento
cur.execute("SELECT id, nome FROM exercicios")
exercicios_map = {nome: id for id, nome in cur.fetchall()}

cur.execute("SELECT id, data FROM treinos")
treinos_map = {data: id for id, data in cur.fetchall()}

for _, row in df.iterrows():
    exercicio_id = exercicios_map[row['exercicio']]
    treino_id = treinos_map[row['data'].date()]
    
    cur.execute("""
        INSERT INTO series
            (treino_id, exercicio_id, numero_serie, repeticoes, peso_kg)
        VALUES (%s, %s, %s ,%s ,%s)
        """, (treino_id, exercicio_id, row['serie'], row['repeticoes'], row['peso_kg']))


conn.commit()
print(f"✅ {len(df)} séries inseridas!") 

cur.close()
conn.close()
print(" Conexão encerrada.")   