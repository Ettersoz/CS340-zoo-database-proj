-- Citation for the following Stored Procedures:
-- Date: 12/05/2024
-- Adapted from: CS 340 - Introduction to Databases
-- Source URL: Course materials and examples from Oregon State University CS340
-- These stored procedures implement CRUD operations for the Zoo Management Database
-- 
-- AI Tool Usage:
-- Claude AI (Anthropic) was used to generate these stored procedures based on the following prompts:
-- 
-- 1. INSERT Procedures:
--    Prompt: "Create a MySQL stored procedure to insert a new animal into the Animals table. 
--    The procedure should accept parameters for name, dateOfBirth, sex, speciesId, and enclosureId. 
--    It should return the new animalId as an output parameter, or -99 if an error occurs. 
--    Include proper transaction handling and error handling."
--
--    Prompt: "Create a MySQL stored procedure to insert a new zookeeper into the Zookeepers table.
--    Accept firstName, lastName, hireDate, and speciality as input parameters. Return the new 
--    keeperId or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to insert a new enclosure into the Enclosures table.
--    Accept enclosureType, location, and maximumCapacity as inputs. Return the new enclosureId 
--    or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to insert a new species into the Species table.
--    Accept name, scientificName, diet, and vertType as inputs. Return the new speciesId or 
--    -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to insert a new enclosure assignment into the 
--    EnclosureAssignments table (M:M relationship). Accept keeperId and enclosureId as inputs. 
--    Return 1 for success or -99 on error."
--
-- 2. UPDATE Procedures:
--    Prompt: "Create a MySQL stored procedure to update an existing animal record. Accept 
--    animalId and all updatable fields (name, dateOfBirth, sex, speciesId, enclosureId) as 
--    parameters. Return the number of rows affected as an output parameter, or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to update an existing zookeeper record. Accept
--    keeperId and all updatable fields (firstName, lastName, hireDate, speciality). Return
--    ROW_COUNT() or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to update an existing enclosure record. Accept
--    enclosureId and all updatable fields (enclosureType, location, maximumCapacity). Return
--    ROW_COUNT() or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to update an existing species record. Accept
--    speciesId and all updatable fields (name, scientificName, diet, vertType). Return
--    ROW_COUNT() or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to update an enclosure assignment (M:M relationship).
--    Accept the old keeperId and enclosureId to identify the record, plus new keeperId and 
--    enclosureId to update it. Return ROW_COUNT() or -99 on error."
--
-- 3. DELETE Procedures:
--    Prompt: "Create a MySQL stored procedure to delete an animal by animalId. Return the 
--    number of rows deleted or -99 on error. Include proper transaction handling."
--
--    Prompt: "Create a MySQL stored procedure to delete a zookeeper by keeperId. The procedure
--    should first delete all related enclosure assignments to prevent data anomalies, then
--    delete the zookeeper. Return ROW_COUNT() or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to delete an enclosure by enclosureId. First
--    delete all related enclosure assignments, then delete the enclosure. Return ROW_COUNT()
--    or -99 on error."
--
--    Prompt: "Create a MySQL stored procedure to delete a species by speciesId. Return
--    ROW_COUNT() or -99 on error with proper transaction handling."
--
--    Prompt: "Create a MySQL stored procedure to delete an enclosure assignment by the
--    composite key (keeperId, enclosureId). Return ROW_COUNT() or -99 on error."

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

