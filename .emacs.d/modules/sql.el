;; "Init module for SQL. Sets evil leader shortcuts for interpreters."
(evil-leader/set-key
  "s q p" 'sql-postgres
  "s q s" 'sql-sqlite)
