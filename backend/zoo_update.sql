DELIMITER //

-- Update animal
DROP PROCEDURE IF EXISTS sp_update_animal //
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

-- Update zookeeper
DROP PROCEDURE IF EXISTS sp_update_zookeeper //
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
DROP PROCEDURE IF EXISTS sp_update_enclosure //
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
DROP PROCEDURE IF EXISTS sp_update_species //
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

-- Update assignment
DROP PROCEDURE IF EXISTS sp_update_assignment //
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

DELIMITER ;