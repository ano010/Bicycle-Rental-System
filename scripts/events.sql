USE brs;

DROP EVENT IF EXISTS yearly_delete_stale_audit_rows;

# event to remove stale audit for bicycle for every year
# reduces memory usage
DELIMITER $$
CREATE EVENT yearly_delete_stale_audit_rows
ON SCHEDULE
EVERY 1 YEAR STARTS '2020-01-01'
DO BEGIN
    DELETE FROM bicycle_audit
    WHERE action_date < NOW() - INTERVAL 1 YEAR ;
END $$
DELIMITER ;