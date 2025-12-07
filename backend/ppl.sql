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

-- ==================== RESET PROCEDURE ====================
DROP PROCEDURE IF EXISTS sp_reset_zoo_database;
CREATE PROCEDURE sp_reset_zoo_database()
BEGIN
    -- Drop existing tables
    SET FOREIGN_KEY_CHECKS = 0;

    DROP TABLE IF EXISTS Zookeepers;
    DROP TABLE IF EXISTS Enclosures;
    DROP TABLE IF EXISTS Species;
    DROP TABLE IF EXISTS Animals;
    DROP TABLE IF EXISTS EnclosureAssignments;

    SET FOREIGN_KEY_CHECKS = 1;

    -- Create tables
    CREATE TABLE Zookeepers (
        keeperId INT UNIQUE NOT NULL AUTO_INCREMENT,
        firstName VARCHAR(50) NOT NULL,
        lastName VARCHAR(50) NOT NULL,
        hireDate DATE NOT NULL,
        speciality VARCHAR(31) NOT NULL,
        PRIMARY KEY (keeperId)
    );

    CREATE TABLE Enclosures (
        enclosureId INT UNIQUE NOT NULL AUTO_INCREMENT,
        enclosureType VARCHAR(50) NOT NULL,
        location VARCHAR(50) NOT NULL, 
        maximumCapacity INT NOT NULL,
        PRIMARY KEY (enclosureId)
    );

    CREATE TABLE Species (
        speciesId INT UNIQUE NOT NULL AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        scientificName VARCHAR(50) NOT NULL,
        diet VARCHAR(15) NOT NULL, 
        vertType VARCHAR(20) NOT NULL,
        PRIMARY KEY (speciesId)
    );

    CREATE TABLE Animals ( 
        animalId INT UNIQUE NOT NULL AUTO_INCREMENT,
        speciesId INT NOT NULL, 
        enclosureId INT NOT NULL,
        dateOfBirth DATE,
        sex VARCHAR(1) NOT NULL,
        name VARCHAR(255) NOT NULL,
        PRIMARY KEY (animalId),
        FOREIGN KEY (speciesId) REFERENCES Species(speciesId) ON DELETE CASCADE,
        FOREIGN KEY (enclosureId) REFERENCES Enclosures(enclosureId) ON DELETE CASCADE
    );

    CREATE TABLE EnclosureAssignments (
        keeperId INT NOT NULL,
        enclosureId INT NOT NULL,
        PRIMARY KEY (keeperId, enclosureId),
        FOREIGN KEY (keeperId) REFERENCES Zookeepers(keeperId) ON DELETE CASCADE,
        FOREIGN KEY (enclosureId) REFERENCES Enclosures(enclosureId) ON DELETE CASCADE
    );

    -- Insert sample data
    INSERT INTO Zookeepers (firstName, lastName, hireDate, speciality) 
    VALUES ('Sarah', 'Johnson', '2018-03-15', 'Mammals'),
    ('Mike', 'Chen', '2019-07-22', 'Reptiles'),
    ('Emma', 'Rodriguez', '2020-01-10', 'Birds'),
    ('James', 'Williams', '2020-01-10', 'Aquatics'),
    ('Lisa', 'Parks', '2021-04-18', 'Primates'); 

    INSERT INTO Enclosures (enclosureType, location, maximumCapacity)
    VALUES ('Savanna Habitat', 'North Wing', 15),
    ('Tropical Rainforest', 'East Section', 20),
    ('Arctic Exhibit', 'South Wing', 8),
    ('Reptile House', 'West Section', 25),
    ('Aviary', 'Central Plaza', 50);

    INSERT INTO Species (name, scientificName, diet, vertType)
    VALUES ('African Lion', 'Panthera leo', 'Carnivor', 'Mammal'),
    ('Red Panda', 'Allurus fulgens', 'Omnivore', 'Mammal'),
    ('Green Anaconda', 'Eunectes murinus', 'Carnivor', 'Reptile'),
    ('Bald Eagle', 'Haliaeetus leucocephalus', 'Carnivor', 'Bird'),
    ('Emperor Penguin', 'Aptenodytes forsteri', 'Carnivor', 'Bird'),
    ('Poison Dart Frog', 'Dendrobates tinctorius', 'Insectivore', 'Amphibians');

    INSERT INTO Animals (speciesId, enclosureId, dateOfBirth, sex, name) 
    VALUES ((SELECT speciesId FROM Species WHERE name = 'African Lion'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Savanna Habitat'),
    '2019-06-12', 'M', 'Simba'),
    ((SELECT speciesId FROM Species WHERE name = 'African Lion'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Savanna Habitat'),
    '2019-06-12', 'F', 'Nala'),
    ((SELECT speciesId FROM Species WHERE name = 'Red Panda'), 
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Tropical Rainforest'),
    '2020-08-03', 'M', 'Rusty'),
    ((SELECT speciesId FROM Species WHERE name = 'Green Anaconda'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Reptile House'),
    '2018-04-20', 'F', 'Squeeze'), 
    ((SELECT speciesId FROM Species WHERE name = 'Emperor Penguin'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Arctic Exhibit'),
    '2022-01-05', 'F', 'Penny'),
    ((SELECT speciesId FROM Species WHERE name = 'Emperor Penguin'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Arctic Exhibit'),
    '2022-01-05', 'M', 'Percy'),
    ((SELECT speciesId FROM Species WHERE name = 'Poison Dart Frog'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Tropical Rainforest'),
    '2023-03-18', 'F', 'Dotty');

    INSERT INTO EnclosureAssignments (keeperId, enclosureId) 
    VALUES ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Sarah' AND lastName = 'Johnson'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Savanna Habitat')),
    ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Sarah' AND lastName = 'Johnson'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Tropical Rainforest')),
    ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Mike' AND lastName = 'Chen'), 
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Reptile House')),
    ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Emma' AND lastName = 'Rodriguez'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Arctic Exhibit')),
    ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Lisa' AND lastName = 'Parks'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Tropical Rainforest')),
    ((SELECT keeperId FROM Zookeepers WHERE firstName = 'Lisa' AND lastName = 'Parks'),
    (SELECT enclosureId FROM Enclosures WHERE enclosureType = 'Savanna Habitat'));
    
END //

DELIMITER ;
