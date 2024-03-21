# lcnc_app

This APP aims to create an application with common functionalities for starter template.

## Setup
- Clone the main app
```bash
  git clone --recurse-submodules git@github.com:michaellarrubis/lcnc_app.git
```
- Switch the branches for both API & CLIENT to `main` or to `other branch`.
- Rename the app with your desired app_name, `lcnc, LCNC Plate` to `[app_name, App Name]`: (Preferrably with VSCode).
  - Open the app in VSCode.
  - press `cmd + shift + h` to find and replace
- lcnc_api, lcnc_client
```bash
  cd lcnc_api && git checkout main
  cd lcnc_client && git checkout main
```
- Run this script to build the services
```bash
  bash scripts/build-services.sh
```
- Once the services are up it will insert the aliases to .zshrc or .bashrc
```bash
  alias gen_migrate="bash $PWD/scripts/migrate.sh"
  alias gen_migrate_seed="bash $PWD/scripts/migrate-seed.sh"

  alias gen_app="bash $PWD/scripts/generate/main.sh"

  alias gen_api="bash $PWD/scripts/generate/api/exec.sh"

  alias gen_api_migration="bash $PWD/scripts/generate/api/migration/index.sh"
  alias gen_api_interface="bash $PWD/scripts/generate/api/interface.sh"
  alias gen_api_swagger="bash $PWD/scripts/generate/api/swagger.sh"
  alias gen_api_route="bash $PWD/scripts/generate/api/route.sh"
  alias gen_api_service="bash $PWD/scripts/generate/api/service.sh"

  alias gen_client="bash $PWD/scripts/generate/client/exec.sh"
  alias gen_client_api="bash $PWD/scripts/generate/client/setup-api.sh"
  alias gen_client_redux="bash $PWD/scripts/generate/client/setup-redux/index.sh"
  alias gen_client_hooks="bash $PWD/scripts/generate/client/setup-hooks/index.sh"
  alias gen_client_page="bash $PWD/scripts/generate/client/setup-page/index.sh"
```
- You need to restart the current terminal or open a new tab.
- Once lcnc_api & lcnc_db is up and running, run this:
```bash
  gen_migrate_seed (*it will migrate and run the seeder)
```
- To stop the services/containers:
```bash
  ctrl + c /
  docker-compose down
```
- To start the services/containers:
```bash
  docker-compose up
```

## Directory Structure
- lcnc_api/
- lcnc_client/
- scripts/
- .env.sample
- .gitignore
- .gitmodules
- docker-compose.yml
- README.md


## Development List Services

- [http://localhost:3002](http://localhost:3002) - Client
- [http://localhost:40024](http://localhost:40024) - API Server
- [http://localhost:40024/api](http://localhost:40024/api) - Swagger
- [http://localhost:5050](http://localhost:5050) - PG Admin GUI
- [http://localhost:8025](http://localhost:8025) - Mailhog Client (Local Mail Server)

## DB ADMIN
- Go to [http://localhost:5050](http://localhost:5050)
```bash
  email: admin@***.inc
  password: password
```
- Click New Server and put this details
```bash
  General
    - Name: LcncPlate Server
  Connection
    - Host name/address: host.docker.internal
    - Port: 5432
    - Maintenance database: lcnc_db
    - Username: postgres
    - Password: root
```

## Model Migration
- Assuming `api` directory is named `lcnc_api`
- Current working directory should be `/app`
```bash
  bash scripts/generate/migration/exec.sh [table_name] [column:type, column:type ...]
```
- Should create 2 files:
  - `lcnc__api/src/database/migrations/files/`
```bash
  - 2023.12.05T02.01.01.[table_name].ts
```
  - `lcnc__api/src/database/models/current`
```bash
  - [table_name].model.ts
```
- Duplicate the content and paste it then create an `audit-[table_name]` -- audit migration file.

## Database Triggers
- Assuming `api` directory is named `lcnc_api`
- All Trigger Functions lies inside the `/sql/trigger_functions`
- See this [https://www.pgadmin.org/docs/pgadmin4/development/trigger_function_dialog.html](DOCS) for setting up with PGAdmin or any DB GUI. 

## Audit Trail Setup

### Source Code Setup
- Directories where audit models should live and where will it be called, assuming that you already have a migration file.
- Create a model file under  `/src/database/models/audit/xxxx.model.ts`.
- Register an interface corresponding to that model in `/src/ts/interfaces/audit.ts` and append the created interface in `type IResult = ... xxx | [INewInterface]`.
- Register the model in `/src/ts/types/index.d.ts` (follow the existing one).

### Database Trigger & Function Location
#### Details
- Each Triggers and Functions should be setup and located in `/sql/trigger_functions/xxx.sql`

#### Setup
- Open [http://localhost:5050](http://localhost:5050)(PostgresDB GUI) - Please see the above setup:
- For reference: `/sql/trigger_functions/base_company.sql`
- Triggers: On PostgresDB GUI:
	- Open a Query Editor, and paste this in the editor:
```bash
  CREATE TRIGGER base_company_trigger
  AFTER INSERT OR UPDATE
  ON base_company
  FOR EACH STATEMENT
  EXECUTE FUNCTION audit_base_company();
```
----
```bash
  CREATE  TRIGGER [model_name]_trigger
  AFTER  INSERT  OR  UPDATE
  ON [model_name]
  FOR EACH STATEMENT
  EXECUTE FUNCTION audit_[model_name]();
```
- Also Functions: On PostgresDB GUI:
	- Open a Query Editor, and paste this in the editor:
```bash
  CREATE OR REPLACE FUNCTION audit_base_company()
  RETURNS trigger
  LANGUAGE plpgsql
  AS $$
  BEGIN
    IF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_base_company(base_company_id, name, logo, email, url, description, address, phone_no, report_email, sender_email, social_media, created_by, updated_by, deleted_by)
        SELECT n.id, n.name, n.logo, n.email, n.url, n.description, n.address, n.phone_no, n.report_email, n.sender_email, n.social_media, n.created_by, n.updated_by, n.deleted_by;
    ELSIF (TG_OP = 'INSERT') THEN
      INSERT INTO audit_base_company(base_company_id, name, logo, email, url, description, address, phone_no, report_email, sender_email, social_media, created_by, updated_by, deleted_by)
        SELECT n.id, n.name, n.logo, n.email, n.url, n.description, n.address, n.phone_no, n.report_email, n.sender_email, n.social_media, n.created_by, n.updated_by, n.deleted_by;
    END IF;

    RETURN NULL;
  END;
  $$
  ;
;
```
---
```bash
  CREATE OR REPLACE FUNCTION audit_[model_name]()
  RETURNS trigger
  LANGUAGE plpgsql
  AS $$
  BEGIN
    IF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_[model_name]([base_model_name]_id, name, logo, email, url, description, address, phone_no, report_email, sender_email, social_media, created_by, updated_by, deleted_by)
        SELECT n.id, n.name, n.logo, n.email, n.url, n.description, n.address, n.phone_no, n.report_email, n.sender_email, n.social_media, n.created_by, n.updated_by, n.deleted_by;
    ELSIF (TG_OP = 'INSERT') THEN
      INSERT INTO audit_[model_name]([base_model_name]_id, name, logo, email, url, description, address, phone_no, report_email, sender_email, social_media, created_by, updated_by, deleted_by)
        SELECT n.id, n.name, n.logo, n.email, n.url, n.description, n.address, n.phone_no, n.report_email, n.sender_email, n.social_media, n.created_by, n.updated_by, n.deleted_by;
    END IF;

    RETURN NULL;
  END;
  $$
;
```

#### TODO
- APP 
  - sh script or flag preferrably (--exclude=*, --include=*) so that it will generate specific files within API or CLIENT

- API
  - rollback generator
  - generator for alteration migration (ALTER, CHANGE columns)

- CLIENT
