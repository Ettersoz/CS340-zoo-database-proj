import GetData from "../components/GetData"


function ZookeeperPage(){
    return(
        <>
            <h1>Zookeepers:</h1>
            <GetData entity={"Zookeepers"}></GetData>
            <button>Add Zookeeper</button>
        </>    
    )
}

export default ZookeeperPage