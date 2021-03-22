package page;

class HelloWorld extends Page {
	public function new() {
		super();
		loadPageTemplate("helloWorld.html");
		jPage.find("button").click( _->App.ME.loadPage( ()->new HelloWorld() ) );
	}
}