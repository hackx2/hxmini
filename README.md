<br>
<br>
<div align="center">
<img src="https://raw.githubusercontent.com/Hackx2/hxmini/refs/heads/main/.resources/logo-noir-ini.png" alt="Matter" width="60%" />
<p>
<strong>Matter.ini 🌌</strong> is a lightweight and simple library for parsing <code>.ini</code> data. <br>It offers an easy way to read, modify, and create your own <code>.ini</code> data.

</p>
</div>



<hr>

<h2>Features :p</h2>
<ul>
<li><strong>Comment Support:</strong> Ignores nodes starting with a semicolon(<code>;</code>) or an hashtag (<code>#</code>).</li>
<li><strong>Multi-line support:</strong> Allows you to define a node using triple quotation marks (<code>""" """</code>)</li>
<li><strong>File Creation & Editing:</strong> Lets you create and edit .ini files</li>
</ul>

<hr>

<h2>Installation 🔧</h2>
<p>You can install the library directly using <code>haxelib</code>.</p>
<pre><code>haxelib install mini</code></pre>
<p>Or you could install using <code>git</code>.</p>
<pre><code>haxelib git mini https://github.com/hackx2/hxmini.git</code></pre>
<hr>

<h2>Usage</h2>

<details>
  <summary>Parse & Access <code>.ini</code> data</summary>
    <p>Here is a simple example of how to use the parser in your Haxe project.</p>
    <p>First, let's assume you have a file named <strong><code>config.ini</code></strong> with the following contents:</p>

  ```ini
  [main.test]
  name="hackx2"
  meows="meow"
  ```

<p>Now, you can parse this file and access its data:</p>

```haxe
import mini.Parser;


// Get `testing.ini`'s file content.
final content : String = sys.io.File.getContent('testing.ini');

// Parse the content.
final ini:Ini = Parser.parse(content);

// Get the element.
final main:Ini = ini.elementsNamed("main.test").next();

// Get and print data.
Sys.println(main.get('name')); // Returns "hackx2"
Sys.println(main.get('meows')); // Returns "meow"

// -----------------------------
```

</details> 

<details>
  <summary>Create your own <code>.ini</code> files</summary>

  <p>Heres how you can create a .ini file:</p>

```haxe
// Create the document.
final ini:Ini = Ini.createDocument();

// Create a Section
final user:Ini = Ini.createSection("User");
user.set("username", "Milo");
user.set("role", "Admin");
user.set("progress", "78%");
ini.addChild(user);

user.get('progress'); // Returns: "78%"

ini.toString(); // Returns the serialized .ini document
```
</details>


<hr>

## Contribution (yippie)
Contributions are always welcome and appreciated!!! 💖If you have a bug or have any suggestions, please open an [issue](https://github.com/hackx2/hxmini/issues).

<hr>

<h2>License</h2>
<p>This project is licensed under the MIT License.</p>