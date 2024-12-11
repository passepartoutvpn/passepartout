let params = new URLSearchParams(document.location.search);
let classes = params.get("classes").split(",");
document.body.className = classes.join(" ");

