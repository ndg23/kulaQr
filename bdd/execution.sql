psql -d votre_base -f bdd/schema.sql
psql -d votre_base -f bdd/policies.sql
psql -d votre_base -f bdd/triggers.sql
psql -d votre_base -f bdd/views.sql
psql -d votre_base -f bdd/seeds.sql  # Optionnel