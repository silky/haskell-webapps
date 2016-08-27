--
-- Tenants
--

create table tenants(
       id serial primary key
       ,name text not null
       ,status text not null default 'inactive'
       ,owner_id integer not null
       ,backoffice_domain text not null
       ,created_at timestamp without time zone not null default current_timestamp
       ,updated_at timestamp without time zone not null default current_timestamp
);
create unique index index_owner_id on tenants(owner_id);
create index status on tenants(status);
create index tenants_created_at on tenants(created_at);
create index tenants_updated_at on tenants(updated_at);
create index tenants_backoffice_domain on tenants(lower(backoffice_domain));

--
-- Users
--

create table users(
       id serial primary key
       ,tenant_id integer not null references tenants(id)
       ,username text not null
       ,password text not null
       ,first_name text
       ,last_name text
       ,status text not null default 'inactive'
       ,created_at timestamp without time zone not null default current_timestamp
       ,updated_at timestamp without time zone not null default current_timestamp
);

create unique index users_username on users(lower(username));
create index users_created_at on users(created_at);
create index users_updated_at on users(updated_at);
create index users_status on users(status);

alter table tenants
      add constraint fk_tenants_owner_id
      foreign key (owner_id)
      references users(id);

--
-- Roles
--

create table roles(
       id serial primary key
       ,tenant_id integer not null references tenants(id)
       ,name text not null
       ,permissions text[] not null constraint at_least_one_permission check (array_length(permissions, 1)>0)
       ,created_at timestamp without time zone not null default current_timestamp
       ,updated_at timestamp without time zone not null default current_timestamp
);
create unique index roles_name on roles(tenant_id, lower(name));
create index roles_created_at on roles(created_at);
create index roles_updated_at on roles(updated_at);

-- TODO: Write a CHECK CONSTRAINT that ensure that permissions[] contains only
-- those permissions that the Haskell ADT can recognize

