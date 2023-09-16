$(document).ready(function() {
    window.addEventListener('message', function(event) {
        if (event.data.Azione === "ApriMenuKill") {
            const Pannello = document.querySelector('.deatshsystembabydrill');
            const Foto = document.querySelector('.img-discord');
            const Nome = document.querySelector('.testo-nome');
            const Id = document.querySelector('.text-id-number');


            Pannello.style.display = "block";
            Foto.src = event.data.Foto;
            Nome.style.innerHTML = event.data.Nome;
            Id.style.innerHTML = event.data.Id;

        }

        if (event.data.Azione === "ChiudiMenuKill") {
            const Pannello = document.querySelector('.deatshsystembabydrill');
            Pannello.style.display = "none";
        }

        if (event.data.Azione === "ApriMenuKillStatus") {
            $("#vita").css("width",  event.data.vita + "%");
        }
    });
});
