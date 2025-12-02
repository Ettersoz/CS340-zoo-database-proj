import { useState, useEffect } from "react";
import BACKEND_URL from "../assets/url";

function AddForm({ entity, onCancel, onSave }) {
    const [formData, setFormData] = useState({});
    const [error, setError] = useState(null);
    const [species, setSpecies] = useState([]);
    const [enclosures, setEnclosures] = useState([]);
    const [zookeepers, setZookeepers] = useState([]);

    useEffect(() => {
        const fetchDropdownData = async () => {
            try {
                if (entity === 'Animals') {
                    const [speciesRes, enclosuresRes] = await Promise.all([
                        fetch(`${BACKEND_URL}/api/Species`),
                        fetch(`${BACKEND_URL}/api/Enclosures`)
                    ]);
                    setSpecies(await speciesRes.json());
                    setEnclosures(await enclosuresRes.json());
                }
                
                if (entity === 'Assignments') {
                    const [zookeepersRes, enclosuresRes] = await Promise.all([
                        fetch(`${BACKEND_URL}/api/Zookeepers`),
                        fetch(`${BACKEND_URL}/api/Enclosures`)
                    ]);
                    setZookeepers(await zookeepersRes.json());
                    setEnclosures(await enclosuresRes.json());
                }
            } catch (err) {
                console.error('Error fetching dropdown data:', err);
            }
        };

        fetchDropdownData();
    }, [entity]);

    const addableFields = {
        'Animals': ['name', 'dateOfBirth', 'sex', 'speciesId', 'enclosureId'],
        'Zookeepers': ['firstName', 'lastName', 'hireDate', 'speciality'],
        'Enclosures': ['enclosureType', 'location', 'maximumCapacity'],
        'Species': ['name', 'scientificName', 'diet', 'vertType'],
        'Assignments': ['keeperId', 'enclosureId']
    };

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await fetch(`${BACKEND_URL}/api/${entity}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            if (!response.ok) {
                throw new Error(`Failed to add`);
            }
            await onSave();
        } catch (err) {
            setError(err.message);
        }
    };

    const renderField = (key) => {
        if (key === 'speciesId' && entity === 'Animals') {
            return (
                <select
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                >
                    <option value="">Select Species</option>
                    {species.map(s => (
                        <option key={s.speciesId} value={s.speciesId}>
                            {s.name} ({s.scientificName})
                        </option>
                    ))}
                </select>
            );
        }
        
        if (key === 'enclosureId') {
            return (
                <select
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                >
                    <option value="">Select Enclosure</option>
                    {enclosures.map(e => (
                        <option key={e.enclosureId} value={e.enclosureId}>
                            {e.enclosureType} - {e.location}
                        </option>
                    ))}
                </select>
            );
        }
        
        if (key === 'keeperId' && entity === 'Assignments') {
            return (
                <select
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                >
                    <option value="">Select Zookeeper</option>
                    {zookeepers.map(z => (
                        <option key={z.keeperId} value={z.keeperId}>
                            {z.firstName} {z.lastName}
                        </option>
                    ))}
                </select>
            );
        }

        if (key === 'dateOfBirth' || key === 'hireDate') {
            return (
                <input
                    type="date"
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                />
            );
        }

        if (key === 'maximumCapacity') {
            return (
                <input
                    type="number"
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                />
            );
        }

        if (key === 'sex') {
            return (
                <select
                    name={key}
                    value={formData[key] || ''}
                    onChange={handleChange}
                    required
                    style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
                >
                    <option value="">Select Sex</option>
                    <option value="M">Male</option>
                    <option value="F">Female</option>
                </select>
            );
        }

        return (
            <input
                type="text"
                name={key}
                value={formData[key] || ''}
                onChange={handleChange}
                required
                style={{ marginLeft: '10px', width: '300px', padding: '5px' }}
            />
        );
    };

    const fieldsToShow = addableFields[entity] || [];

    return (
        <div style={{ border: '2px solid #333', padding: '20px', margin: '10px 0', backgroundColor: '#f0f0f0' }}>
            <h3>Add New {entity}</h3>
            {error && <p style={{ color: 'red' }}>Error: {error}</p>}
            
            <form onSubmit={handleSubmit}>
                {fieldsToShow.map((key) => (
                    <div key={key} style={{ marginBottom: '10px' }}>
                        <label>
                            {key}:
                            {renderField(key)}
                        </label>
                    </div>
                ))}

                <button type="submit" style={{ padding: '8px 16px' }}>Add</button>
                <button type="button" onClick={onCancel} style={{ marginLeft: '10px', padding: '8px 16px' }}>Cancel</button>
            </form>
        </div>
    );
}

export default AddForm;