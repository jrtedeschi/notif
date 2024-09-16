import time
import logging
import requests
import pandas as pd
import duckdb


def timeit(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        logger.info(f"Function {func.__name__} took {end_time - start_time:.4f} seconds")
        return result
    return wrapper

@timeit
def get_data(url, params: dict):
    response = requests.get(url, params=params)
    data = response.json()
    return data

@timeit
def insert_data(con, table_name, data):
    df = pd.DataFrame(data)
    for col in df.columns:
        if col.startswith('acc'):
            df[col].replace('-', None, inplace=True)

    df['datahoraUltimovalor'] = pd.to_datetime(df['datahoraUltimovalor'])
    # SUBTRACT 3 HOURS FROM TIMESTAMP
    df['datahoraUltimovalor'] = df['datahoraUltimovalor'] - pd.Timedelta(hours=3)

    con.sql("INSERT INTO {} SELECT * FROM df ".format(table_name))
    return df


@timeit
def create_table(con, table_name):
    con.execute('''
CREATE TABLE IF NOT EXISTS pluviometria (
    idestacao INTEGER,
    uf TEXT,
    codibge INTEGER,
    cidade TEXT,
    nomeestacao TEXT,
    ultimovalor DOUBLE,
    datahoraUltimovalor TIMESTAMP,
    acc1hr DOUBLE,
    acc3hr DOUBLE,
    acc6hr DOUBLE,
    acc12hr DOUBLE,
    acc24hr DOUBLE,
    acc48hr DOUBLE,
    acc72hr DOUBLE,
    acc96hr DOUBLE,
    tipoestacao INTEGER,
    status INTEGER
)
''')
# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@timeit
def main():
    ufs = ['SP', 'RJ', 'MG', 'ES', 'PR', 'SC', 'RS', 'MS', 'MT', 'GO', 'DF', 'BA', 'SE', 'AL', 'PE', 'PB', 'RN', 'CE', 'PI', 'MA', 'PA', 'AP', 'TO', 'RR', 'AM', 'AC', 'RO']

    # Connect to DuckDB (in-memory or file-based)
    con = duckdb.connect(database=':memory:', read_only=False)
    logger.info("Connected to DuckDB")


    for uf in ufs:
        logger.info(f"Getting data for {uf}")
        create_table(con, 'pluviometria')
        data = get_data("https://resources.cemaden.gov.br/graficos/interativo/getJson2.php", params={'uf': uf})
        logger.info(f"Inserting data for {uf}")
        insert_data(con, 'pluviometria', data)

    con.table('pluviometria').show()

    return con

if __name__ == "__main__":
    con = main()


    con.sql("SELECT * FROM pluviometria WHERE acc24hr > 80.0").show()
