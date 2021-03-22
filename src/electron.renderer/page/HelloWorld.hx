package page;

class HelloWorld extends Page {
	public function new() {
		super();
		loadPageTemplate("helloWorld.html");
	}
}