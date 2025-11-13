import GetData from "../components/GetData"


function SpeciesPage(){
    return(
        <>
            <h1>Species:</h1>
            <GetData entity={"Species"}></GetData>
            <button>Add Species</button>
        </>    
    )
}

export default SpeciesPage