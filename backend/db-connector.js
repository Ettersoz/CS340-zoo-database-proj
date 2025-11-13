// Get an instance of mysql we can use in the app
const mysql = require("mysql2");

/*
    IF YOUR TRYING TO PUT SERVER INTO PRODUCTION, ALL VALUES UNDER 'host' MUST BE CHANGED TO USER SPECIFIC VALUES!!!
*/

// Create a 'connection pool' using the provided credentials
const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit: 10,
    host: 'classmysql.engr.oregonstate.edu',
    user: 'cs340_YOUR ONID', // example: cs340_MyOnidIsBilboBaggins
    password: 'YOUR PASSWORD', // last 4 of your OSU ID number
    database: 'cs340_YOUR ONID' // should be same as user
}).promise(); // This makes it so we can use async / await rather than callbacks

// Export it for use in our application
module.exports = pool;