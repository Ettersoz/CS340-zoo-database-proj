import GetData from "../components/GetData"


function EnclosurePage(){
    return(
        <>
            <h1>Enclosures:</h1>
            <GetData entity={"Enclosures"}></GetData>
            <button>Add Enclosure</button>
        </>    
    )
}

export default EnclosurePage