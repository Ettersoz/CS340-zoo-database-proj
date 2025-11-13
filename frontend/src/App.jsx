import './App.css'
import Navigation from './components/Navigation';
import HomePage from './pages/HomePage';
import EnclosurePage from './pages/EnclosurePage';
import ZookeeperPage from './pages/ZookeeperPage';
import SpeciesPage from './pages/SpeciesPage';
import AnimalPage from './pages/AnimalPage';
import EnclosureAssignmentsPage from './pages/EnclosureAssignmentsPage';
import {BrowserRouter as Router, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <>
      <Router>
        <Navigation/>
        <Routes>
          <Route path='/' element={<HomePage />}></Route>
          <Route path='/enclosures' element={<EnclosurePage />}></Route>
          <Route path='/zookeepers' element={<ZookeeperPage />}></Route>
          <Route path='/animals' element={<AnimalPage />}></Route>
          <Route path='/species' element={<SpeciesPage />}></Route>
          <Route path='/enclosureassignments' element={<EnclosureAssignmentsPage />}></Route>
        </Routes>
      </Router>
    </>
  )
}

export default App