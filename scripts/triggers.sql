USE brs;

DROP TRIGGER IF EXISTS store_after_insert;
DROP TRIGGER IF EXISTS store_after_delete;

# updating number of bicycle in a store after a new bicycle added
# transaction handled
DELIMITER $$
CREATE TRIGGER store_after_insert
    AFTER INSERT ON bicycle
    FOR EACH ROW
BEGIN
    UPDATE store
    SET number_of_bicycles = number_of_bicycles + 1
    WHERE store.id = NEW.store_id;

    INSERT INTO bicycle_audit
    VALUES (NEW.id, NEW.model, NEW.status, NEW.store_id, 'Insert', NOW());

END $$
DELIMITER ;

# updating number of bicycle in a store after a bicycle removed
# log the record into bicycle_audit
DELIMITER $$
CREATE TRIGGER store_after_delete
    AFTER DELETE ON bicycle
    FOR EACH ROW
BEGIN
    UPDATE store
    SET number_of_bicycles = number_of_bicycles - 1
    WHERE store.id = OLD.store_id;

    INSERT INTO bicycle_audit
    VALUES (OLD.id, OLD.model, OLD.status, OLD.store_id, 'Delete', NOW());
END $$
DELIMITER ;

# login changes for the data for auditing
# security and backup

DROP TABLE IF EXISTS bicycle_audit;
CREATE TABLE bicycle_audit(
    bicycle_id INT(10) NOT NULL,
    model VARCHAR(50),
    status VARCHAR(45) NOT NULL ,
    store_id INT(3) NOT NULL ,
    action_type VARCHAR(50) NOT NULL ,
    action_date DATETIME NOT NULL
);