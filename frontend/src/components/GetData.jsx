import { useState, useEffect } from "react";
import BACKEND_URL from "../assets/url";
import EditForm from "./EditForm";
import AddForm from "./AddForm";

function GetData({ entity }) {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [editingRecord, setEditingRecord] = useState(null);
    const [showAddForm, setShowAddForm] = useState(false);

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

    useEffect(() => {
        fetchData();
    }, [entity]);

    const handleEdit = (record) => {
        setEditingRecord(record);
        setShowAddForm(false); // Close add form when editing
    };

    const handleCancelEdit = () => {
        setEditingRecord(null);
    };

    const handleSaveEdit = async () => {
        setEditingRecord(null);
        await fetchData();
    };

    const handleDelete = async (record) => {
        if (!window.confirm('Are you sure you want to delete this record?')) {
            return;
        }

        try {
            let url;
            if (entity === 'Assignments') {
                url = `${BACKEND_URL}/api/${entity}/${record.keeperId}/${record.enclosureId}`;
            } else {
                const idFieldMap = {
                    'Animals': 'animalId',
                    'Zookeepers': 'keeperId',
                    'Enclosures': 'enclosureId',
                    'Species': 'speciesId'
                };
                const idField = idFieldMap[entity];
                const id = record[idField];
                url = `${BACKEND_URL}/api/${entity}/${id}`;
            }

            const response = await fetch(url, { method: 'DELETE' });
            
            if (!response.ok) {
                throw new Error('Failed to delete');
            }
            
            await fetchData();
        } catch (err) {
            alert('Error deleting: ' + err.message);
        }
    };

    const handleAdd = () => {
        setShowAddForm(true);
        setEditingRecord(null); // Close edit form when adding
    };

    const handleCancelAdd = () => {
        setShowAddForm(false);
    };

    const handleSaveAdd = async () => {
        setShowAddForm(false);
        await fetchData();
    };

    if (loading) return <p>Loading {entity}...</p>;
    if (error) return <p>Error: {error}</p>;

    return (
        <div>
            <button onClick={handleAdd} style={{ marginBottom: '10px', padding: '8px 16px' }}>
                Add New {entity}
            </button>

            {showAddForm && (
                <AddForm 
                    entity={entity}
                    onCancel={handleCancelAdd}
                    onSave={handleSaveAdd}
                />
            )}

            {editingRecord && (
                <EditForm 
                    entity={entity}
                    record={editingRecord}
                    onCancel={handleCancelEdit}
                    onSave={handleSaveEdit}
                />
            )}

            {data.length === 0 ? (
                <p>No {entity} found. Click "Add New" to create one.</p>
            ) : (
                <table border="1" cellPadding="10">
                    <thead> 
                        <tr>
                            {Object.keys(data[0]).map((col) => (
                                <th key={col}>{col}</th>
                            ))}
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    {data.map((item, index) => (
                        <tr key={index}>
                            {Object.keys(data[0]).map((col) => (
                                <td key={col}>{item[col]}</td>
                            ))}
                            <td>
                                <button onClick={() => handleEdit(item)}>Edit</button>
                                <button 
                                    onClick={() => handleDelete(item)} 
                                    style={{ marginLeft: '5px', backgroundColor: '#ff4444', color: 'white' }}
                                >
                                    Delete
                                </button>
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

export default GetData;