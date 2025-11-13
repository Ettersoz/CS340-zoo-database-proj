import { Link } from "react-router-dom";

function Navigation(){
    return(
        <nav>
            <Link to='/'>Home Page </Link>
            <Link to='/animals'>Animal </Link>
            <Link to='/enclosures'>Enclosures </Link>
            <Link to='/species'>Species </Link>
            <Link to='/zookeepers'>Zookeepers </Link>
            <Link to='/enclosureassignments'>Zookeepers </Link>
        </nav>
    )
}

export default Navigation