import { useState } from "react";
import BACKEND_URL from "../assets/url"  

function EditForm({ entity, record, onCancel, onSave }) {
    const [formData, setFormData] = useState({ ...record });
    const [error, setError] = useState(null);

    const [species, setSpecies] = useState([]);
    const [enclosures, setEnclosures] = useState([]);
    const [zookeepers, setZookeepers] = useState([]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const idField = `${entity.toLowerCase().slice(0, -1)}Id`;
            const id = record[idField];
            const response = await fetch(`${BACKEND_URL}/api/${entity}/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });
            if (!response.ok) {
                throw new Error(`Failed to update`);
            }
            onSave();
        } catch (err) {
            setError(err.message);
        }
    };

    return (
        <div> 
            <h3>Edit {entity}</h3>
            {error && <p style={{ color: 'red' }}>Error: {error}</p>}
            
            <form onSubmit={handleSubmit}>
                {Object.keys(formData).map((key) => {
                    if (key.endsWith('Id')) return null; // Skip ID fields
                    return (
                        <div key={key}>
                            <label>
                                {key}:
                                <input
                                    type="text"
                                    name={key}
                                    value={formData[key] || ''}
                                    onChange={handleChange}
                                />
                            </label>
                        </div>
                    );
                })}

                <button type="submit">Save</button>
                <button type="button" onClick={onCancel}>Cancel</button>
            </form>
        </div>
    );
}

export default EditForm;