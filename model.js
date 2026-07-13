async function loadCompetitors(){

    const response = await fetch("/api/competitors");

    const data = await response.json();

    console.log(data);

}

loadCompetitors();