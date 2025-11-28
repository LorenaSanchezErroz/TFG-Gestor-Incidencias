 // NO MOVER DE AQUÍ ESTA FUNCIÓN, SI NO NO FUNCIONA
 // redirección a la página web de la lavandería al pulsar el icono 
 const logo = document.querySelector(".icono"); // logoripo de boreas
 logo.addEventListener('click', () => {
    window.location.href = "https://www.lavanderiaboreas.com/"
 });

 
 
 // Selección de elementos (input e iconos)

 const inputPass = document.getElementById("password")
 const vista = document.getElementById("vista");
 const novista = document.getElementById("novista")


// Función al hacer click en el ojo tachado para poder VER

novista.onclick = function() {
    novista.style.display = 'none';
    vista.style.display = 'block';
    inputPass.type = 'text'; // pasamos a text para poder leer la contraseña
}


// Función al hacer click en el ojo para poder OCULTAR

vista.onclick = function() {
    vista.style.display='none';
    novista.style.display='block';
    inputPass.type = 'password'; // pasamos a password para ocultarlo
}


// Valdar Login

function validarLogin(event) {
    event.preventDefault(); // Evita recarga automática

    // Aquí iría tu lógica de validación (ej. conectar con base de datos)
    
    // Simulación que el login es correcto:
    const loginExitoso = true;
    
    if (loginExitoso) {
        window.location.href = "html/historial.html"; // Redirige si está todo bien
    } else {
        alert("Usuario o contraseñas incorrectos");
    }

}

       