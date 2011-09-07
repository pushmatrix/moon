(function() {
  var Key, Scene, Ship;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Key = (function() {
    function Key() {}
    Key.UP = 38;
    Key.DOWN = 40;
    Key.LEFT = 37;
    Key.RIGHT = 39;
    window.addEventListener('keyup', (__bind(function(event) {
      return this.onKeyup(event);
    }, Key)), false);
    window.addEventListener('keydown', (__bind(function(event) {
      return this.onKeydown(event);
    }, Key)), false);
    Key._pressed = {};
    Key.isDown = function(keyCode) {
      return this._pressed[keyCode];
    };
    Key.onKeydown = function(event) {
      return this._pressed[event.keyCode] = true;
    };
    Key.onKeyup = function(event) {
      return delete this._pressed[event.keyCode];
    };
    return Key;
  }).call(this);
  Scene = (function() {
    Scene.prototype.createRenderer = function() {
      this.container = document.createElement('div');
      document.body.appendChild(this.container);
      this.renderer = new THREE.WebGLRenderer({
        antialias: true
      });
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.container.appendChild(this.renderer.domElement);
      if (typeof Stats !== "undefined" && Stats !== null) {
        this.stats = new Stats();
        this.stats.domElement.style.position = 'absolute';
        this.stats.domElement.style.top = '0px';
        this.container.appendChild(this.stats.domElement);
      }
      return window.addEventListener('resize', __bind(function() {
        var h, w;
        w = window.innerWidth;
        h = window.innerHeight;
        this.camera.aspect = w / h;
        this.camera.updateProjectionMatrix();
        return this.renderer.setSize(w, h);
      }, this));
    };
    Scene.prototype.render = function(time) {
      var target, timestep;
      requestAnimationFrame(this.render, this.renderer.domElement);
      timestep = (time - this.lastFrameTime) * 0.001;
      this.stats.update();
      if (Key.isDown(Key.UP)) {
        this.ship.addPitch(-1);
      }
      if (Key.isDown(Key.DOWN)) {
        this.ship.addPitch(1);
      }
      if (Key.isDown(Key.LEFT)) {
        this.ship.addRoll(1);
      }
      if (Key.isDown(Key.RIGHT)) {
        this.ship.addRoll(-1);
      }
      this.ship.tick(timestep);
      target = this.ship.position.clone().subSelf(this.ship.direction().multiplyScalar(-3));
      this.camera.quaternion = THREE.Quaternion.slerp(this.camera.quaternion, this.ship.quaternion, new THREE.Quaternion, 0.15).normalize();
      this.camera.position = this.camera.position.addSelf(target.subSelf(this.camera.position).multiplyScalar(0.1));
      this.renderer.render(this.scene, this.camera);
      return this.lastFrameTime = time;
    };
    function Scene() {
      this.render = __bind(this.render, this);      var material, skyShader, skyTexture, urlPrefix, urls;
      this.camera = new THREE.Camera(45, window.innerWidth / window.innerHeight, 1, 10000);
      this.camera.position.z = 2;
      this.camera.useTarget = false;
      this.camera.useQuaternion = true;
      this.scene = new THREE.Scene;
      this.planet = new THREE.Mesh(new THREE.SphereGeometry(0.5, 20, 20), new THREE.MeshPhongMaterial({
        map: THREE.ImageUtils.loadTexture("images/earth.jpg"),
        color: 0xFF99FF
      }));
      this.planet.position.z = -1.9;
      this.addObject(this.planet);
      urlPrefix = "images/";
      urls = [urlPrefix + "stars.png", urlPrefix + "stars.png", urlPrefix + "stars.png", urlPrefix + "stars.png", urlPrefix + "stars.png", urlPrefix + "stars.png"];
      skyTexture = THREE.ImageUtils.loadTextureCube(urls);
      skyShader = THREE.ShaderUtils.lib["cube"];
      skyShader.uniforms["tCube"].texture = skyTexture;
      material = new THREE.MeshShaderMaterial({
        uniforms: skyShader.uniforms,
        vertexShader: skyShader.vertexShader,
        fragmentShader: skyShader.fragmentShader
      });
      this.space = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), material);
      this.space = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), material);
      this.addObject(this.space);
      this.ship = new Ship();
      this.addObject(this.ship);
      this.light = new THREE.PointLight(0xffffff);
      this.light.position = this.camera.position;
      this.scene.addLight(this.light);
      this.createRenderer();
      this.lastFrameTime = Date.now();
      requestAnimationFrame(this.render, this.renderer.domElement);
    }
    Scene.prototype.addObject = function(object) {
      return this.scene.addObject(object);
    };
    return Scene;
  })();
  THREE.Mesh.loader = new THREE.JSONLoader();
  window.onload = function() {
    var game;
    game = new Scene();
    window.game = game;
    return window.key = Key;
  };
  Ship = (function() {
    __extends(Ship, THREE.Object3D);
    function Ship() {
      Ship.__super__.constructor.call(this);
      this.velocity = 0;
      this.useQuaternion = true;
      this.pitchVelocity = 0;
      this.rollVelocity = 0;
      THREE.Mesh.loader.load({
        model: 'ship.js',
        callback: __bind(function(geometry) {
          var material, mesh;
          material = new THREE.MeshPhongMaterial({
            ambient: 0xff9900,
            specular: 0xff9900,
            shininess: 100
          });
          mesh = new THREE.Mesh(geometry, material);
          mesh.scale = new THREE.Vector3(0.2, 0.2, 0.2);
          return this.addChild(mesh);
        }, this)
      });
    }
    Ship.prototype.direction = function() {
      var c_orient_axis;
      c_orient_axis = new THREE.Vector3();
      this.quaternion.multiplyVector3(new THREE.Vector3(0, 0, 1), c_orient_axis);
      return c_orient_axis;
    };
    Ship.prototype.addPitch = function(direction) {
      this.pitchVelocity += 0.001 * direction;
      if (this.pitchVelocity > 0.05) {
        return this.pitchVelocity = 0.05;
      } else if (this.pitchVelocity < -0.05) {
        return this.pitchVelocity = -0.05;
      }
    };
    Ship.prototype.addRoll = function(direction) {
      this.rollVelocity += 0.001 * direction;
      if (this.rollVelocity > 0.05) {
        return this.rollVelocity = 0.05;
      } else if (this.rollVelocity < -0.05) {
        return this.rollVelocity = -0.05;
      }
    };
    Ship.prototype.tick = function(timestep) {
      var pitch, roll;
      pitch = new THREE.Quaternion();
      pitch.setFromAxisAngle(new THREE.Vector3(1, 0, 0), this.pitchVelocity);
      roll = new THREE.Quaternion();
      roll.setFromAxisAngle(new THREE.Vector3(0, 0, 1), this.rollVelocity);
      this.quaternion.multiplySelf(pitch).multiplySelf(roll);
      this.pitchVelocity *= 0.98;
      this.rollVelocity *= 0.98;
      return this.position.subSelf(this.direction().multiplyScalar(0.05));
    };
    return Ship;
  })();
}).call(this);
