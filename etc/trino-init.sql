create schema if not exists minio.people
with (location = 's3a://people/');

create table if not exists minio.people.people (
  name varchar,
  age integer,
  hair varchar
)
with (
  external_location = 's3a://people/',
  format = 'JSON'
);


create schema if not exists minio.autos
with (location = 's3a://autos/');

create table if not exists minio.autos.cars (
  id integer,
  make varchar,
  model varchar,
  year integer
)
with (
  external_location = 's3a://autos/cars',
  format = 'ORC'
);

create table if not exists minio.autos.owners (
  car_id integer,
  person_name varchar,
  color varchar
)
with (
  external_location = 's3a://autos/owners',
  format = 'PARQUET'
);


insert into minio.people.people (name, age, hair) values
  ('Brendan', 34, 'brown'), ('Chantale', 34, 'brown'),
  ('Blondie', 55, 'blonde'), ('The Ginge', 22, 'red');

insert into minio.autos.cars (id, make, model, year) values
  (1, 'Ford', 'Taurus', 1990), (2, 'Mitsubishi', 'Outlander', 2018),
  (3, 'Chevy', 'Tahoe', 2002), (4, 'Honda', 'Civic', 2012);

insert into minio.autos.owners (car_id, person_name, color) values
  (1, 'The Ginge', 'yellow'), (2, 'Brendan', 'black'),
  (4, 'Blondie', 'red');


-- create or replace view minio.autos.car_values as
-- select p.name, p.age, o.color, c.make, c.model, v.value
-- from minio.people.people p -- Gzipped JSON format
-- left join minio.autos.owners o on p.name = o.person_name -- ORC
-- left join minio.autos.cars c on o.car_id = c.id -- Parquet
-- left join postgresql.autos.car_values v on -- PostgreSQL server
--   c.make = v.make and c.model = v.model and c.year = v.year;
