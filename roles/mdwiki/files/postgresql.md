## Всякое полезное

### Немного про установку sudo
```bash
nano /etc/apt/sources.list # Правим список репозиториев
apt update                 # Дергаем apt чтобы он перечитал список
apt install net-tools      # Ставим netstat, ifconfig итд

apt install sudo     # Установил утилиту sudo
visudo               # Отредактировал файлик /etc/sudoers с помощью встроенной утилиты
                     # Запустится текстовый редактор по-умолчанию. Обычно nano, но может и vim
usermod -aG sudo mak # Добавил пользователя mak в группу sudo, чтобы разрешить ему пользоваться
```

Выдержка из /etc/sudoers:
```bash
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
```


### Немного про su и sudo
```bash
su -    # Становлюсь рутом, ввожу пароль РУТА. Сменю переменные окружения за счет аргумента минус
sudo -i # Становлюсь рутом, ввожу пароль СВОЕГО пользователя (mak). Сменю переменные окружения за счет ключа i
```


### Clone VMs
```bash
hostnamectl set-hostname db3.devmail.ru
nano /etc/hosts
nano /etc/network/interfaces
```


## Установка PostgreSQL

> default postgresql port 5432

```bash
apt install postgresql postgresql-contrib

nano /etc/postgresql/11/main/postgresql.conf # Редактирование основного файла конфигурации
nano /etc/postgresql/11/main/pg_hba.conf     # Редактирование файла аутентификации

systemctl restart postgresql
systemctl status postgresql
```

Про HBA можно почитать [тут](https://postgrespro.ru/docs/postgrespro/10/auth-pg-hba-conf).
Простецкая [статейка](https://devacademy.ru/article/kak-ustanovit-postgresql-na-debian-10) по установке и настройке.


## Немного полезных команд PosgreSQL

У постгри как мы вчера выяснили есть исполняемые утилиты для создания пользователей:
```bash
sudo -iu posgres
createuser developer
createdb newdb
psql -c "grant all privileges on database newdb to developer;"
```

Откатим это:
```sql
revoke all on database newdb from developer;
drop user developer;
drop database newdb;
```

Создадим все целиком с помощью SQL. Канонично, удобно.
```sql
CREATE DATABASE testdb;
CREATE USER testuser WITH ENCRYPTED PASSWORD 'testpass';
GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;
```

Пример вывода:
```
postgres@mysuperserver:~$ psql
psql (11.12 (Debian 11.12-0+deb10u1))
Type "help" for help.

postgres=# CREATE DATABASE testdb;
CREATE DATABASE
postgres=# CREATE USER testuser WITH ENCRYPTED PASSWORD 'testpass';
CREATE ROLE
postgres=# GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;
GRANT
```

Не забудем добавить в конец файлика HBA нашего нового пользователя:
```bash
echo "host testdb testuser 0.0.0.0/0 md5" >> /etc/postgresql/11/main/pg_hba.conf
systemctl reload postgresql # И перезагрузить конфигурацию
```

Поправим файл ключей для основного пользователя, формат `hostname:port:database:username:password`:
```bash
nano ~/.pgpass
psql --host db1.devmail.ru testdb -U testuser
```

Создадим таблицу и заполним ее тестовыми данными:
```sql
CREATE TABLE users (
    user_id int PRIMARY KEY,
    username varchar(25) NOT NULL,
    password varchar(30) NOT NULL
);

INSERT INTO users(user_id, username, password)
VALUES (1, 'mak', 'НуПустиУжеЖелезякаБездушная'),
       (2, 'lae', 'ЗеленыеГлазаТоп'),
       (3, 'ddd', 'ДефолтДефолтовичДефолт');
```

```
mak@db1:~$ psql --host db1.devmail.ru testdb -U testuser
psql (11.12 (Debian 11.12-0+deb10u1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

testdb=> select * from users;
 user_id | username |          password           
---------+----------+-----------------------------
       1 | mak      | НуПустиУжеЖелезякаБездушная
       2 | lae      | ЗеленыеГлазаТоп
       3 | ddd      | ДефолтДефолтовичДефолт
(3 rows)

testdb=> \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 testdb    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres         +
           |          |          |             |             | postgres=CTc/postgres+
           |          |          |             |             | testuser=CTc/postgres
(4 rows)

testdb=> \q
```

## Собираем кластер

Офигенная [статья](https://www.dmosk.ru/miniinstruktions.php?mini=postgresql-replication) от офигенного чувака.
Устаревшая [статья](https://eax.me/postgresql-replication/), но там хорошо рассмотрели как оно под капотом работает.

На всякий случай обезопасим админского пользователя:
```sql
ALTER ROLE postgres ENCRYPTED PASSWORD 'postgrespass';
```

Создадим пользователя для репликации с паролем 'replpass' (спросит при запуске утилиты):
```bash
createuser --replication -P repluser
```

### На мастере

Меняем в основном конфиге:
```
listen_addresses = '*'
wal_level = replica
max_wal_senders = 4
max_replication_slots = 4
hot_standby = on
hot_standby_feedback = on
```
В HBA добавляем repluser-а. Рестартим. После добавления реплик смотрим:
```sql
select * from pg_stat_replication;
```


### На слейве

```bash
PG_DATA_DIR=$(su - postgres -c "psql -c 'SHOW data_directory;'"  | head -n3 | tail -n1)

systemctl stop posgresql

tar -czvf /tmp/data_pgsql.tar.gz $PG_DATA_DIR  # Делаем резеврную копию
rm -rf $PG_DATA_DIR                            # Удаляем старые данные
```

Копируем все с мастера и довозим настройки репликации
```bash
su - postgres -c \
"pg_basebackup --host=db1.devmail.ru --username=repluser --pgdata=/var/lib/postgresql/11/main --wal-method=stream --write-recovery-conf"
```

Меняем в основном конфиге:
```
listen_addresses = '*'
```

Перезапускаем.
Смотрим:
```sql
select * from pg_stat_wal_receiver;
```
