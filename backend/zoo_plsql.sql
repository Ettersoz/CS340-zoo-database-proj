DELIMITER //

-- ==================== INSERT PROCEDURES ====================

-- Insert new animal
DROP PROCEDURE IF EXISTS sp_insert_animal;
CREATE PROCEDURE sp_insert_animal(
    IN p_name VARCHAR(255),
    IN p_dateOfBirth DATE,
    IN p_sex VARCHAR(1),
    IN p_speciesId INT,
    IN p_enclosureId INT,
    OUT p_animalId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_animalId = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    INSERT INTO Animals (name, dateOfBirth, sex, speciesId, enclosureId)
    VALUES (p_name, p_dateOfBirth, p_sex, p_speciesId, p_enclosureId);
    
    SET p_animalId = LAST_INSERT_ID();
    
    COMMIT;
END //

-- Insert new enclosure assignment (M:M)
DROP PROCEDURE IF EXISTS sp_insert_assignment;
CREATE PROCEDURE sp_insert_assignment(
    IN p_keeperId INT,
    IN p_enclosureId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    INSERT INTO EnclosureAssignments (keeperId, enclosureId)
    VALUES (p_keeperId, p_enclosureId);
    
    SET p_success = 1;
    
    COMMIT;
END //

-- Insert new zookeeper
DROP PROCEDURE IF EXISTS sp_insert_zookeeper;
CREATE PROCEDURE sp_insert_zookeeper(
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_hireDate DATE,
    IN p_speciality VARCHAR(31),
    OUT p_keeperId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_keeperId = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    INSERT INTO Zookeepers (firstName, lastName, hireDate, speciality)
    VALUES (p_firstName, p_lastName, p_hireDate, p_speciality);
    
    SET p_keeperId = LAST_INSERT_ID();
    
    COMMIT;
END //

-- Insert new enclosure
DROP PROCEDURE IF EXISTS sp_insert_enclosure;
CREATE PROCEDURE sp_insert_enclosure(
    IN p_enclosureType VARCHAR(50),
    IN p_location VARCHAR(50),
    IN p_maximumCapacity INT,
    OUT p_enclosureId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_enclosureId = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    INSERT INTO Enclosures (enclosureType, location, maximumCapacity)
    VALUES (p_enclosureType, p_location, p_maximumCapacity);
    
    SET p_enclosureId = LAST_INSERT_ID();
    
    COMMIT;
END //

-- Insert new species
DROP PROCEDURE IF EXISTS sp_insert_species;
CREATE PROCEDURE sp_insert_species(
    IN p_name VARCHAR(255),
    IN p_scientificName VARCHAR(50),
    IN p_diet VARCHAR(15),
    IN p_vertType VARCHAR(20),
    OUT p_speciesId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_speciesId = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    INSERT INTO Species (name, scientificName, diet, vertType)
    VALUES (p_name, p_scientificName, p_diet, p_vertType);
    
    SET p_speciesId = LAST_INSERT_ID();
    
    COMMIT;
END //

-- ==================== UPDATE PROCEDURES ====================

-- Update animal
DROP PROCEDURE IF EXISTS sp_update_animal;
CREATE PROCEDURE sp_update_animal(
    IN p_animalId INT,
    IN p_name VARCHAR(255),
    IN p_dateOfBirth DATE,
    IN p_sex VARCHAR(1),
    IN p_speciesId INT,
    IN p_enclosureId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    UPDATE Animals
    SET name = p_name,
        dateOfBirth = p_dateOfBirth,
        sex = p_sex,
        speciesId = p_speciesId,
        enclosureId = p_enclosureId
    WHERE animalId = p_animalId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Update enclosure assignment (M:M)
DROP PROCEDURE IF EXISTS sp_update_assignment;
CREATE PROCEDURE sp_update_assignment(
    IN p_old_keeperId INT,
    IN p_old_enclosureId INT,
    IN p_new_keeperId INT,
    IN p_new_enclosureId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    UPDATE EnclosureAssignments
    SET keeperId = p_new_keeperId,
        enclosureId = p_new_enclosureId
    WHERE keeperId = p_old_keeperId AND enclosureId = p_old_enclosureId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Update zookeeper
DROP PROCEDURE IF EXISTS sp_update_zookeeper;
CREATE PROCEDURE sp_update_zookeeper(
    IN p_keeperId INT,
    IN p_firstName VARCHAR(50),
    IN p_lastName VARCHAR(50),
    IN p_hireDate DATE,
    IN p_speciality VARCHAR(31),
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    UPDATE Zookeepers
    SET firstName = p_firstName,
        lastName = p_lastName,
        hireDate = p_hireDate,
        speciality = p_speciality
    WHERE keeperId = p_keeperId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Update enclosure
DROP PROCEDURE IF EXISTS sp_update_enclosure;
CREATE PROCEDURE sp_update_enclosure(
    IN p_enclosureId INT,
    IN p_enclosureType VARCHAR(50),
    IN p_location VARCHAR(50),
    IN p_maximumCapacity INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    UPDATE Enclosures
    SET enclosureType = p_enclosureType,
        location = p_location,
        maximumCapacity = p_maximumCapacity
    WHERE enclosureId = p_enclosureId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Update species
DROP PROCEDURE IF EXISTS sp_update_species;
CREATE PROCEDURE sp_update_species(
    IN p_speciesId INT,
    IN p_name VARCHAR(255),
    IN p_scientificName VARCHAR(50),
    IN p_diet VARCHAR(15),
    IN p_vertType VARCHAR(20),
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    UPDATE Species
    SET name = p_name,
        scientificName = p_scientificName,
        diet = p_diet,
        vertType = p_vertType
    WHERE speciesId = p_speciesId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- ==================== DELETE PROCEDURES ====================

-- Delete animal
DROP PROCEDURE IF EXISTS sp_delete_animal;
CREATE PROCEDURE sp_delete_animal(
    IN p_animalId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    DELETE FROM Animals WHERE animalId = p_animalId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Delete enclosure assignment (M:M)
DROP PROCEDURE IF EXISTS sp_delete_assignment;
CREATE PROCEDURE sp_delete_assignment(
    IN p_keeperId INT,
    IN p_enclosureId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    DELETE FROM EnclosureAssignments
    WHERE keeperId = p_keeperId AND enclosureId = p_enclosureId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Delete zookeeper (with cascade to assignments)
DROP PROCEDURE IF EXISTS sp_delete_zookeeper;
CREATE PROCEDURE sp_delete_zookeeper(
    IN p_keeperId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    -- First delete assignments (prevent data anomaly)
    DELETE FROM EnclosureAssignments WHERE keeperId = p_keeperId;
    
    -- Then delete zookeeper
    DELETE FROM Zookeepers WHERE keeperId = p_keeperId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Delete enclosure (with cascade to assignments)
DROP PROCEDURE IF EXISTS sp_delete_enclosure;
CREATE PROCEDURE sp_delete_enclosure(
    IN p_enclosureId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    -- First delete assignments
    DELETE FROM EnclosureAssignments WHERE enclosureId = p_enclosureId;
    
    -- Then delete enclosure
    DELETE FROM Enclosures WHERE enclosureId = p_enclosureId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

-- Delete species
DROP PROCEDURE IF EXISTS sp_delete_species;
CREATE PROCEDURE sp_delete_species(
    IN p_speciesId INT,
    OUT p_success INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = -99;
        ROLLBACK;
    END;

    START TRANSACTION;
    
    DELETE FROM Species WHERE speciesId = p_speciesId;
    
    SET p_success = ROW_COUNT();
    
    COMMIT;
END //

DELIMITER ;

