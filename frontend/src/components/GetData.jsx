import BACKEND_URL from "../assets/url"  // Adjust path based on where getData.jsx is

const getData = async function(entity) {
    try {
        const response = await fetch(`${BACKEND_URL}/api/${entity}`);
        
        if (!response.ok) {
            throw new Error(`Failed to fetch ${entity}: ${response.status}`);
        }
        
        const rows = await response.json();
        return rows;
        
    } catch (error) {
        console.error(`Error fetching ${entity}:`, error);
        throw error;
    } 
}

export default getData;
