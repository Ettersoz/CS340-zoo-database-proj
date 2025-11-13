// Express library used to create a web server that will listen and respond to API calls from the frontend
const db = require('./db-connector');
// Test the database connection
db.query('SELECT 1')
    .then(() => {
        console.log('Database connection successful');
    })
    .catch((err) => {
        console.error('Database connection failed:', err);
        process.exit(1);
    });

const MY_ONID = "ettersoz";
const express = require('express');

// Instantiate an express object to interact with the server
const app = express();

// Middleware to allow cross-origin requests
const cors = require('cors');

// Set a port in the range: 1024 < PORT < 65535
const PORT = 8373;


// If on FLIP or classwork, use cors() middleware to allow cross-origin requests from the frontend with your port number:
// EX (local): http://localhost:5173
// EX (FLIP/classwork) http://classwork.engr.oregonstate.edu:5173
app.use(cors({ credentials: true, origin: "*" }));
app.use(express.json()); // this is needed for post requests, good thing to know
            
// Route handler 

// Get all animals with their species and enclosure info
app.get('/api/Animals', async (req, res) => {
    try {
        const query = `
            SELECT 
                a.animalId,
                a.name,
                a.dateOfBirth,
                a.sex,
                a.speciesId,
                a.enclosureId,
                s.name AS speciesName,
                s.scientificName,
                s.diet,
                s.vertType,
                e.enclosureType,
                e.location
            FROM Animals a
            JOIN Species s ON a.speciesId = s.speciesId
            JOIN Enclosures e ON a.enclosureId = e.enclosureId
            ORDER BY a.name;
        `;
        
        const [rows] = await db.query(query);
        res.status(200).json(rows);
    } catch (error) {
        console.error("Error fetching animals:", error);
        res.status(500).send("Error fetching animals");
    }
});

// Update an animal by ID
app.put('/api/Animals/:id', async (req, res) => {
    try {
        const animalId = req.params.id;
        const { name, dateOfBirth, sex, speciesId, enclosureId } = req.body;

        const query = `
            UPDATE Animals
            SET name = ?, dateOfBirth = ?, sex = ?, speciesId = ?, enclosureId = ?
            WHERE animalId = ?;
        `;
        const [result] = await db.query(query, [name, dateOfBirth, sex, speciesId, enclosureId, animalId]);

        if (result.affectedRows === 0) {
            return res.status(404).send("Animal not found");
        }

        res.status(200).send("Animal updated successfully");
    } catch (error) {
        console.error("Error updating animal:", error);
        res.status(500).send("Error updating animal");
    }
});

// Get all zookeepers
app.get('/api/Zookeepers', async (req, res) => {
    try {
        const query = 'SELECT * FROM Zookeepers ORDER BY lastName, firstName;';
        const [rows] = await db.query(query);
        res.status(200).json(rows);
    } catch (error) {
        console.error("Error fetching zookeepers:", error);
        res.status(500).send("Error fetching zookeepers");
    }
});

// Update a zookeeper by ID
app.get('/api/Zookeepers:id', async (req, res) => {
    try {
        const keeperId = req.params.id;
        const { firstName, lastName, hireDate, specialty } = req.body;

        const query = `
            UPDATE Zookeepers
            SET firstName = ?, lastName = ?, hireDate = ?, specialty = ?
            WHERE keeperId = ?;
        `;
        const [result] = await db.query(query, [firstName, lastName, hireDate, specialty, keeperId]);

        if (result.affectedRows === 0) {
            return res.status(404).send("Zookeeper not found");
        }

        res.status(200).send("Zookeeper updated successfully");
    } catch (error) {
        console.error("Error updating zookeeper:", error);
        res.status(500).send("Error updating zookeeper");
    }
});

// Get all enclosures
app.get('/api/Enclosures', async (req, res) => {
    try {
        const query = 'SELECT * FROM Enclosures ORDER BY location;';
        const [rows] = await db.query(query);
        res.status(200).json(rows);
    } catch (error) {
        console.error("Error fetching enclosures:", error);
        res.status(500).send("Error fetching enclosures");
    }
});

// Update an enclosure by ID
app.get('/api/Enclosures/:id', async (req, res) => {
    try {
        const enclosureId = req.params.id;
        const { enclosureType, location, maximumCapacity } = req.body;
        
        const query = `UPDATE Enclosures
                       SET enclosureType = ?, location = ?, maximumCapacity = ?
                       WHERE enclosureId = ?;`;

        const [result] = await db.query(query, [enclosureType, location, maximumCapacity, enclosureId]);

        if (result.affectedRows === 0) {
            return res.status(404).send("Enclosure not found");
        }

        res.status(200).send("Enclosure updated successfully");
    } catch (error) {
        console.error("Error updating enclosure:", error);
        res.status(500).send("Error updating enclosure");
    }
});

// Get all species
app.get('/api/Species', async (req, res) => {
    try {
        const query = 'SELECT * FROM Species ORDER BY name;';
        const [rows] = await db.query(query);
        res.status(200).json(rows);
    } catch (error) {
        console.error("Error fetching species:", error);
        res.status(500).send("Error fetching species");
    }
});

// Update a species by ID
app.get('/api/Species/:id', async (req, res) => {
    try {
        const speciesId = req.params.id;
        const { name, scientificName, diet, vertType } = req.body;
        
        const query = `UPDATE Species
                       SET name = ?, scientificName = ?, diet = ?, vertType = ?
                       WHERE speciesId = ?;`;

        const [result] = await db.query(query, [name, scientificName, diet, vertType, speciesId]);

        if (result.affectedRows === 0) {
            return res.status(404).send("Species not found");
        }

        res.status(200).send("Species updated successfully");
    } catch (error) {
        console.error("Error updating species:", error);
        res.status(500).send("Error updating species");
    }
});

// Get enclosure assignments (which keepers are assigned to which enclosures)
app.get('/api/Assignments', async (req, res) => {
    try {
        const query = `
            SELECT 
                ea.keeperId,
                ea.enclosureId,
                CONCAT(z.firstName, ' ', z.lastName) AS keeperName,
                z.speciality,
                e.enclosureType,
                e.location
            FROM EnclosureAssignments ea
            JOIN Zookeepers z ON ea.keeperId = z.keeperId
            JOIN Enclosures e ON ea.enclosureId = e.enclosureId
            ORDER BY keeperName;
        `;
        
        const [rows] = await db.query(query);
        res.status(200).json(rows);
    } catch (error) {
        console.error("Error fetching assignments:", error);
        res.status(500).send("Error fetching assignments");
    }
});

// Update an enclosure assignment
app.put('/api/Assignments/:keeperId/:enclosureId', async (req, res) => {
    try {
        const { keeperId, enclosureId } = req.params;
        const { newKeeperId, newEnclosureId } = req.body;
        
        const query = `
            UPDATE EnclosureAssignments 
            SET keeperId = ?, enclosureId = ?
            WHERE keeperId = ? AND enclosureId = ?
        `;
        
        const [result] = await db.query(query, [newKeeperId, newEnclosureId, keeperId, enclosureId]);
        
        if (result.affectedRows === 0) {
            return res.status(404).send("Assignment not found");
        }
        
        res.status(200).json({ message: "Assignment updated successfully" });
    } catch (error) {
        console.error("Error updating assignment:", error);
        res.status(500).send("Error updating assignment");
    }
});

// Tell express what port to listen on 
const server = app.listen(PORT, function () {
    console.log('Express started on http://classwork.engr.oregonstate.edu:' + PORT + '; press Ctrl-C to terminate.');
});

server.on('error', (err) => {
    console.error('Server error:', err);
    process.exit(1);
});