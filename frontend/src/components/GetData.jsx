import { useState, useEffect } from "react";
import BACKEND_URL from "../assets/url"  // Adjust path based on where getData.jsx is


function GetData({ entity }) {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const response = await fetch(`${BACKEND_URL}/api/${entity}`);
                
                if (!response.ok) {
                    throw new Error(`Failed to fetch ${entity}: ${response.status}`);
                }
                
                const rows = await response.json();
                setData(rows);
                setError(null);
            } catch (err) {
                setError(err.message);
                setData([]);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [entity]);

    if (loading) return <p>Loading {entity}...</p>;
    if (error) return <p>Error: {error}</p>;
    if (data.length === 0) return <p>No {entity} found.</p>;


    const columns = Object.keys(data[0]);

    return (
        <div> 
            <table border="1" cellPadding="10">
                <thead> 
                    <tr>
                        {columns.map((col) => (
                            <th key={col}>{col}</th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                {data.map((item, index) => (
                    <tr key={index}>
                        {columns.map((col) => (
                            <td key={col}>{item[col]}</td>
                        ))}
                    </tr>
                ))}
                </tbody>
            </table>
        </div>
    );
}

export default GetData;