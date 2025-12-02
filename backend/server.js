const db = require('./db-connector');
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 8375;

// Test the database connection
db.query('SELECT 1')
    .then(() => {
        console.log('Database connection successful');
    })
    .catch((err) => {
        console.error('Database connection failed:', err);
        process.exit(1);
    });

app.use(cors({ credentials: true, origin: "*" }));
app.use(express.json());

// ==================== ANIMALS ====================

app.get('/api/Animals', async (req, res) => {
    try {
        const query = `
            SELECT 
                a.animalId, a.name, a.dateOfBirth, a.sex, a.speciesId, a.enclosureId,
                s.name AS speciesName, s.scientificName, s.diet, s.vertType,
                e.enclosureType, e.location
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

app.put('/api/Animals/:id', async (req, res) => {
    try {
        const animalId = req.params.id;
        const { name, dateOfBirth, sex, speciesId, enclosureId } = req.body;

        // FIXED: Split into two queries
        await db.query(
            'CALL sp_update_animal(?, ?, ?, ?, ?, ?, @success);',
            [animalId, name, dateOfBirth, sex, speciesId, enclosureId]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Animal not found or update failed");
        }
        
        res.status(200).send("Animal updated successfully");
    } catch (error) {
        console.error("Error updating animal:", error);
        res.status(500).send("Error updating animal");
    }
});

// ==================== ZOOKEEPERS ====================

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

app.put('/api/Zookeepers/:id', async (req, res) => {
    try {
        const keeperId = req.params.id;
        const { firstName, lastName, hireDate, speciality } = req.body;

        // FIXED: Split into two queries
        await db.query(
            'CALL sp_update_zookeeper(?, ?, ?, ?, ?, @success);',
            [keeperId, firstName, lastName, hireDate, speciality]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Zookeeper not found or update failed");
        }
        
        res.status(200).send("Zookeeper updated successfully");
    } catch (error) {
        console.error("Error updating zookeeper:", error);
        res.status(500).send("Error updating zookeeper");
    }
});

// ==================== ENCLOSURES ====================

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

app.put('/api/Enclosures/:id', async (req, res) => {
    try {
        const enclosureId = req.params.id;
        const { enclosureType, location, maximumCapacity } = req.body;
        
        // FIXED: Split into two queries
        await db.query(
            'CALL sp_update_enclosure(?, ?, ?, ?, @success);',
            [enclosureId, enclosureType, location, maximumCapacity]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Enclosure not found or update failed");
        }
        
        res.status(200).send("Enclosure updated successfully");
    } catch (error) {
        console.error("Error updating enclosure:", error);
        res.status(500).send("Error updating enclosure");
    }
});

// ==================== SPECIES ====================

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

app.put('/api/Species/:id', async (req, res) => {
    try {
        const speciesId = req.params.id;
        const { name, scientificName, diet, vertType } = req.body;
        
        // FIXED: Split into two queries
        await db.query(
            'CALL sp_update_species(?, ?, ?, ?, ?, @success);',
            [speciesId, name, scientificName, diet, vertType]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Species not found or update failed");
        }
        
        res.status(200).send("Species updated successfully");
    } catch (error) {
        console.error("Error updating species:", error);
        res.status(500).send("Error updating species");
    }
});

// ==================== ASSIGNMENTS (M:M) ====================

app.get('/api/Assignments', async (req, res) => {
    try {
        const query = `
            SELECT 
                ea.keeperId, ea.enclosureId,
                CONCAT(z.firstName, ' ', z.lastName) AS keeperName,
                z.speciality,
                e.enclosureType, e.location
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

app.put('/api/Assignments/:keeperId/:enclosureId', async (req, res) => {
    try {
        const { keeperId, enclosureId } = req.params;
        const { newKeeperId, newEnclosureId } = req.body;
        
        // FIXED: Split into two queries
        await db.query(
            'CALL sp_update_assignment(?, ?, ?, ?, @success);',
            [keeperId, enclosureId, newKeeperId, newEnclosureId]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Assignment not found or update failed");
        }
        
        res.status(200).json({ message: "Assignment updated successfully" });
    } catch (error) {
        console.error("Error updating assignment:", error);
        res.status(500).send("Error updating assignment");
    }
});

app.delete('/api/Animals/:id', async (req, res) => {
    try {
        const animalId = req.params.id;
        
        await db.query('CALL sp_delete_animal(?, @success);', [animalId]);
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Animal not found or delete failed");
        }
        
        res.status(200).send("Animal deleted successfully");
    } catch (error) {
        console.error("Error deleting animal:", error);
        res.status(500).send("Error deleting animal");
    }
});

// Delete zookeeper
app.delete('/api/Zookeepers/:id', async (req, res) => {
    try {
        const keeperId = req.params.id;
        
        await db.query('CALL sp_delete_zookeeper(?, @success);', [keeperId]);
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Zookeeper not found or delete failed");
        }
        
        res.status(200).send("Zookeeper deleted successfully");
    } catch (error) {
        console.error("Error deleting zookeeper:", error);
        res.status(500).send("Error deleting zookeeper");
    }
});

// Delete enclosure
app.delete('/api/Enclosures/:id', async (req, res) => {
    try {
        const enclosureId = req.params.id;
        
        await db.query('CALL sp_delete_enclosure(?, @success);', [enclosureId]);
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Enclosure not found or delete failed");
        }
        
        res.status(200).send("Enclosure deleted successfully");
    } catch (error) {
        console.error("Error deleting enclosure:", error);
        res.status(500).send("Error deleting enclosure");
    }
});

// Delete species
app.delete('/api/Species/:id', async (req, res) => {
    try {
        const speciesId = req.params.id;
        
        await db.query('CALL sp_delete_species(?, @success);', [speciesId]);
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Species not found or delete failed");
        }
        
        res.status(200).send("Species deleted successfully");
    } catch (error) {
        console.error("Error deleting species:", error);
        res.status(500).send("Error deleting species");
    }
});

// Delete assignment (M:M)
app.delete('/api/Assignments/:keeperId/:enclosureId', async (req, res) => {
    try {
        const { keeperId, enclosureId } = req.params;
        
        await db.query('CALL sp_delete_assignment(?, ?, @success);', [keeperId, enclosureId]);
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99 || success === 0) {
            return res.status(404).send("Assignment not found or delete failed");
        }
        
        res.status(200).send("Assignment deleted successfully");
    } catch (error) {
        console.error("Error deleting assignment:", error);
        res.status(500).send("Error deleting assignment");
    }
});

// ==================== INSERT ENDPOINTS ====================

// Insert animal
app.post('/api/Animals', async (req, res) => {
    try {
        const { name, dateOfBirth, sex, speciesId, enclosureId } = req.body;
        
        await db.query(
            'CALL sp_insert_animal(?, ?, ?, ?, ?, @animalId);',
            [name, dateOfBirth, sex, speciesId, enclosureId]
        );
        
        const [result] = await db.query('SELECT @animalId AS animalId;');
        const animalId = result[0].animalId;
        
        if (animalId === -99) {
            return res.status(400).send("Error inserting animal");
        }
        
        res.status(201).json({ animalId });
    } catch (error) {
        console.error("Error inserting animal:", error);
        res.status(500).send("Error inserting animal");
    }
});

// Insert zookeeper
app.post('/api/Zookeepers', async (req, res) => {
    try {
        const { firstName, lastName, hireDate, speciality } = req.body;
        
        await db.query(
            'CALL sp_insert_zookeeper(?, ?, ?, ?, @keeperId);',
            [firstName, lastName, hireDate, speciality]
        );
        
        const [result] = await db.query('SELECT @keeperId AS keeperId;');
        const keeperId = result[0].keeperId;
        
        if (keeperId === -99) {
            return res.status(400).send("Error inserting zookeeper");
        }
        
        res.status(201).json({ keeperId });
    } catch (error) {
        console.error("Error inserting zookeeper:", error);
        res.status(500).send("Error inserting zookeeper");
    }
});

// Insert enclosure
app.post('/api/Enclosures', async (req, res) => {
    try {
        const { enclosureType, location, maximumCapacity } = req.body;
        
        await db.query(
            'CALL sp_insert_enclosure(?, ?, ?, @enclosureId);',
            [enclosureType, location, maximumCapacity]
        );
        
        const [result] = await db.query('SELECT @enclosureId AS enclosureId;');
        const enclosureId = result[0].enclosureId;
        
        if (enclosureId === -99) {
            return res.status(400).send("Error inserting enclosure");
        }
        
        res.status(201).json({ enclosureId });
    } catch (error) {
        console.error("Error inserting enclosure:", error);
        res.status(500).send("Error inserting enclosure");
    }
});

// Insert species
app.post('/api/Species', async (req, res) => {
    try {
        const { name, scientificName, diet, vertType } = req.body;
        
        await db.query(
            'CALL sp_insert_species(?, ?, ?, ?, @speciesId);',
            [name, scientificName, diet, vertType]
        );
        
        const [result] = await db.query('SELECT @speciesId AS speciesId;');
        const speciesId = result[0].speciesId;
        
        if (speciesId === -99) {
            return res.status(400).send("Error inserting species");
        }
        
        res.status(201).json({ speciesId });
    } catch (error) {
        console.error("Error inserting species:", error);
        res.status(500).send("Error inserting species");
    }
});

// Insert assignment (M:M)
app.post('/api/Assignments', async (req, res) => {
    try {
        const { keeperId, enclosureId } = req.body;
        
        await db.query(
            'CALL sp_insert_assignment(?, ?, @success);',
            [keeperId, enclosureId]
        );
        
        const [result] = await db.query('SELECT @success AS success;');
        const success = result[0].success;
        
        if (success === -99) {
            return res.status(400).send("Error creating assignment");
        }
        
        res.status(201).send("Assignment created successfully");
    } catch (error) {
        console.error("Error creating assignment:", error);
        res.status(500).send("Error creating assignment");
    }
});

// ==================== RESET DATABASE ====================

app.post('/api/reset', async (req, res) => {
    try {
        await db.query('CALL sp_reset_zoo_database();');
        res.status(200).send("Database reset successfully");
    } catch (error) {
        console.error("Error resetting database:", error);
        res.status(500).send("Error resetting database");
    }
});

// ==================== START SERVER ====================

const server = app.listen(PORT, function () {
    console.log('Express started on http://classwork.engr.oregonstate.edu:' + PORT + '; press Ctrl-C to terminate.');
});

server.on('error', (err) => {
    console.error('Server error:', err);
    process.exit(1);
});