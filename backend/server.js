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


// Tell express what port to listen on 
const server = app.listen(PORT, function () {
    console.log('Express started on http://classwork.engr.oregonstate.edu:' + PORT + '; press Ctrl-C to terminate.');
});

server.on('error', (err) => {
    console.error('Server error:', err);
    process.exit(1);
});