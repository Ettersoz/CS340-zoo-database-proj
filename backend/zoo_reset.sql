DROP PROCEDURE IF EXISTS sp_reset_zoo_database;

DELIMITER //

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

-- To use: CALL sp_reset_zoo_database();