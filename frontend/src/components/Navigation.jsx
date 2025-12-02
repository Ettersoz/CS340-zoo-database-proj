import { Link } from "react-router-dom";
import { useState } from "react";
const BACKEND_URL = "http://classwork.engr.oregonstate.edu:8375";

function Navigation(){
    const [loading, setLoading] = useState(false);

    const handleReset = async () => {
        if (!window.confirm('Reset database to original state?')) return;
        
        setLoading(true);
        try {
            await fetch(`${BACKEND_URL}/api/reset`, { method: 'POST' });
            alert('Database reset! Refresh your pages.');
        } catch (error) {
            alert('Reset failed: ' + error.message);
        }
        setLoading(false);
    };

    return(
        <nav>
            <Link to='/'>Home Page </Link>
            <Link to='/animals'>Animal </Link>
            <Link to='/enclosures'>Enclosures </Link>
            <Link to='/species'>Species </Link>
            <Link to='/zookeepers'>Zookeepers </Link>
            <Link to='/enclosureassignments'>Enclosure Assignments </Link>
            <button onClick={handleReset} disabled={loading}>
                {loading ? 'Resetting...' : 'RESET'}
            </button>
        </nav>
    )
}

export default Navigation