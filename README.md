ibm\_db Foreign Key bug example
===============================

Bug
---

This app reproduces [ibmdb/ruby-ibmdb#52][1], where invalid foreign key
constraints are added to schema.rb after migrating.

[1]: https://github.com/ibmdb/ruby-ibmdb/issues/52

Reproducing
-----------

1. Clone this repository
2. Create a `config/database.yml` configuration appropriate for your local
   setup. Include `schema: IBM_DB_BUG` in the database configuration for
   isolation and consistency with this example. Example:

    ```yaml
    development:
      adapter: ibm_db
      host: "127.0.0.1"
      username: "user"
      password: "pass"
      database: "database"
      schema: IBM_DB_BUG
    ```
4. Run migrations: `rake db:migrate`. In addition to running successfully, your
   `schema.rb` should have no significant changes.

5. Manually create this valid foreign key constraint:

    ```sql
    ALTER TABLE "IBM_DB_BUG"."AUDIT_DETAILS"
            ADD CONSTRAINT "FK_AUDDTL_ID" FOREIGN KEY
                    ("AUDIT_ID")
            REFERENCES "IBM_DB_BUG"."AUDITS"
                    ("ID")
            ON DELETE CASCADE
            ON UPDATE RESTRICT
            ENFORCED
            ENABLE QUERY OPTIMIZATION;
    ```

6. Run `rake db:migrate` again to update `schema.rb`.

Actual Behavior
---------------

`schema.rb` contains:

```ruby
add_foreign_key "AUDIT_DETAILS", "AUDITS", column: "AUDIT_ID", primary_key: "ID", name: "FK_AUDDTL_ID", on_update: :cascade, on_delete: :restrict
```

Note that the actions in schema.rb are swapped from the actual constraint
actions:

```ruby
on_update: :cascade, on_delete: :restrict
```

```sql
ON DELETE CASCADE
ON UPDATE RESTRICT
```

Expected Behavior
-----------------

The same line in `schema.rb` contains these actions

```ruby
on_update: :restrict, on_delete: :cascade
```

Cleanup
-------

Remove database artifacts introduced by this app:

```SQL
DROP TABLE IBM_DB_BUG.AUDIT_DETAILS;
DROP TABLE IBM_DB_BUG.AUDITS;
CALL SYSPROC.ADMIN_DROP_SCHEMA('IBM_DB_BUG', NULL, 'ERRORSCHEMA', 'ERRORTABLE');
DROP TABLE ERRORSCHEMA.ERRORTABLE;
```
