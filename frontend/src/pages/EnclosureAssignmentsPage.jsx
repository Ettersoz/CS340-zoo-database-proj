import GetData from "../components/GetData"


function EnclosureAssignmentsPage(){
    return(
        <>
            <h1>EnclosureAssignments:</h1>
            <GetData entity={"EnclosureAssignments"}></GetData>
            <button>Add EnclosureAssignment</button>
        </>    
    )
}

export default EnclosureAssignmentsPage