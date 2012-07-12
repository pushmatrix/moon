(function() {
  var Client, Key, Moon, Player, Scene, clock, publicUrl;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Client = (function() {
    var now;
    now = window.now;
    function Client(game) {
      this.game = game;
      now.addPlayers = __bind(function(players) {
        var id, player, _results;
        _results = [];
        for (id in players) {
          player = players[id];
          this.game.addPlayer(id, player.position, this.id() === id);
          console.log("CREATING " + id);
          _results.push(console.log("I AM " + (this.id())));
        }
        return _results;
      }, this);
      now.removePlayer = __bind(function(id) {
        var player;
        player = this.game.players[id];
        if (player) {
          game.scene.remove(player);
          this.game.players[id] = null;
          return delete this.game.players[id];
        }
      }, this);
      now.updatePlayer = __bind(function(player) {
        if (player.id === this.id()) {
          return;
        }
        if (this.game.players[player.id]) {
          this.game.players[player.id].position.x = player.position.x;
          this.game.players[player.id].position.y = player.position.y;
          this.game.players[player.id].position.z = player.position.z;
          return window.player = this.game.players[player.id];
        }
      }, this);
      setInterval(this.sendUpdate, 33);
    }
    Client.prototype.id = function() {
      return now.core.clientId;
    };
    Client.prototype.sendUpdate = function() {
      return now.sendUpdate({
        position: this.game.player.position
      });
    };
    return Client;
  })();
  clock = new THREE.Clock();
  publicUrl = "/public/";
  Key = (function() {
    function Key() {}
    Key.UP = 38;
    Key.DOWN = 40;
    Key.LEFT = 37;
    Key.RIGHT = 39;
    Key.SPACE = 32;
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
        return this.renderer.setSize(w, h);
      }, this));
    };
    function Scene() {
      this.render = __bind(this.render, this);
      var aspect, far, fov, geometry, material, near, skyMaterial, skyShader, skyTexture, urls;
      this.scene = new THREE.Scene;
      fov = 50;
      aspect = window.innerWidth / window.innerHeight;
      near = 1;
      far = 100000;
      this.camera = new THREE.PerspectiveCamera(fov, aspect, near, far);
      this.scene.add(this.camera);
      this.players = {};
      this.moon = new Moon(128, 128, 127, 127);
      this.add(this.moon);
      urls = ["" + publicUrl + "/stars.png", "" + publicUrl + "/stars.png", "" + publicUrl + "/stars.png", "" + publicUrl + "/stars.png", "" + publicUrl + "/stars.png", "" + publicUrl + "/stars.png"];
      skyTexture = THREE.ImageUtils.loadTextureCube(urls);
      skyTexture.wrapS = THREE.RepeatWrapping;
      skyTexture.wrapT = THREE.RepeatWrapping;
      skyTexture.repeat.x = 100;
      skyTexture.repeat.y = 100;
      skyShader = THREE.ShaderUtils.lib["cube"];
      skyShader.uniforms["tCube"].texture = skyTexture;
      skyMaterial = new THREE.ShaderMaterial({
        uniforms: skyShader.uniforms,
        vertexShader: skyShader.vertexShader,
        fragmentShader: skyShader.fragmentShader,
        depthWrite: false
      });
      this.skybox = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), skyMaterial);
      this.skybox.flipSided = true;
      this.add(this.skybox);
      geometry = new THREE.PlaneGeometry(128, 128, 1, 1);
      material = new THREE.MeshLambertMaterial({
        map: THREE.ImageUtils.loadTexture("/public/milk.jpg")
      });
      this.milk = new THREE.Mesh(geometry, material);
      this.milk.doubleSided = true;
      this.milk.position.y = 5;
      this.add(this.milk);
      this.earth = new THREE.Mesh(new THREE.SphereGeometry(50, 20, 20), new THREE.MeshLambertMaterial({
        map: THREE.ImageUtils.loadTexture("/public/earth.jpg"),
        color: 0x0
      }));
      this.earth.position.z = 500;
      this.earth.position.y = 79;
      this.earth.rotation.y = 2.54;
      this.add(this.earth);
      this.light = new THREE.PointLight(0xffffff);
      this.ambient = new THREE.AmbientLight(0x999999);
      this.light.position = this.camera.position;
      this.add(this.light);
      this.add(this.ambient);
      this.scene.fog = new THREE.Fog(0xffffff, 1, 10000);
      this.createRenderer();
    }
    Scene.prototype.add = function(object) {
      return this.scene.add(object);
    };
    Scene.prototype.addPlayer = function(id, position, currentPlayer) {
      var p;
      if (position == null) {
        position = new THREE.Vector3(7, 15, 7);
      }
      if (currentPlayer == null) {
        currentPlayer = false;
      }
      p = new Player(position);
      this.players[id] = p;
      this.add(p);
      if (currentPlayer) {
        this.player = p;
        return requestAnimationFrame(this.render, this.renderer.domElement);
      }
    };
    Scene.prototype.render = function(time) {
      var delta, mapHeightAtCamera, mapHeightAtPlayer, target, timestep;
      if (!this.player) {
        return;
      }
      delta = clock.getDelta();
      requestAnimationFrame(this.render, this.renderer.domElement);
      timestep = (time - this.lastFrameTime) * 0.001;
      this.stats.update();
      if (Key.isDown(Key.UP)) {
        this.player.forward(1);
      }
      if (Key.isDown(Key.DOWN)) {
        this.player.forward(-1);
      }
      if (Key.isDown(Key.LEFT)) {
        this.player.turn(1);
      }
      if (Key.isDown(Key.RIGHT)) {
        this.player.turn(-1);
      }
      if (Key.isDown(Key.SPACE)) {
        this.player.jump(1);
      }
      this.player.update(delta);
      mapHeightAtPlayer = this.moon.getHeight(this.player.position.x, this.player.position.z);
      if (mapHeightAtPlayer > this.player.position.y - 0.8) {
        this.player.position.y = mapHeightAtPlayer + 0.8;
        this.player.jumping = false;
      }
      target = this.player.position.clone().subSelf(this.player.direction().multiplyScalar(-8));
      this.camera.position = this.camera.position.addSelf(target.subSelf(this.camera.position).multiplyScalar(0.1));
      mapHeightAtCamera = this.moon.getHeight(this.camera.position.x, this.camera.position.z);
      if (mapHeightAtCamera > (this.player.position.y - 2)) {
        this.camera.position.y = mapHeightAtCamera + 2;
        this.player.jumping = false;
      }
      this.camera.lookAt(this.player.position);
      if (this.player.position.y < (this.milk.position.y - 3)) {
        this.scene.fog.far = 20;
      } else {
        this.scene.fog.far = 10000;
      }
      this.earth.rotation.y += 0.01;
      this.earth.rotation.z += 0.005;
      this.earth.rotation.x += 0.005;
      return this.renderer.render(this.scene, this.camera);
    };
    return Scene;
  })();
  $(document).ready(function() {
    var client, game;
    game = new Scene();
    client = new Client(game);
    window.game = game;
    return window.key = Key;
  });
  Player = (function() {
    __extends(Player, THREE.Object3D);
    function Player(position) {
      Player.__super__.constructor.call(this);
      this.position = position;
      this.velocity = 0;
      this.yVelocity = 0;
      this.speed = 0.05;
      this.maxSpeed = 0.2;
      this.angularVelocity = 0;
      this.turnSpeed = 0.01;
      this.maxTurnSpeed = 0.02;
      this.useQuaternion = true;
      this.jumping = false;
      this.texture = THREE.ImageUtils.loadTexture("/public/robot.png");
      this.sprite = new THREE.Sprite({
        map: this.texture,
        useScreenCoordinates: false,
        color: 0xffffff
      });
      this.sprite.scale.y = 0.02;
      this.sprite.scale.x = 0.015;
      this.add(this.sprite);
    }
    Player.prototype.direction = function() {
      var c_orient_axis;
      c_orient_axis = new THREE.Vector3();
      this.quaternion.multiplyVector3(new THREE.Vector3(0, 0, 1), c_orient_axis);
      return c_orient_axis;
    };
    Player.prototype.forward = function(direction) {
      this.velocity += this.speed * direction;
      if (this.velocity > this.maxSpeed) {
        return this.velocity = this.maxSpeed;
      } else if (this.velocity < -this.maxSpeed) {
        return this.velocity = -this.maxSpeed;
      }
    };
    Player.prototype.jump = function(direction) {
      if (!this.jumping) {
        this.yVelocity = this.speed;
        return this.jumping = true;
      }
    };
    Player.prototype.turn = function(direction) {
      this.angularVelocity += this.turnSpeed * direction;
      if (this.angularVelocity > this.maxTurnSpeed) {
        return this.angularVelocity = this.maxTurnSpeed;
      } else if (this.angularVelocity < -this.maxTurnSpeed) {
        return this.angularVelocity = -this.maxTurnSpeed;
      }
    };
    Player.prototype.update = function(timestep) {
      var rotation;
      rotation = new THREE.Quaternion();
      rotation.setFromAxisAngle(new THREE.Vector3(0, 1, 0), this.angularVelocity);
      this.quaternion.multiplySelf(rotation);
      this.angularVelocity *= 0.9;
      this.velocity *= 0.8;
      this.position.subSelf(this.direction().multiplyScalar(this.velocity));
      this.position.y += this.yVelocity;
      return this.yVelocity -= 0.0005;
    };
    return Player;
  })();
  Moon = (function() {
    __extends(Moon, THREE.Object3D);
    function Moon(width, height, numRows, numCols) {
      var img;
      this.width = width;
      this.height = height;
      this.numRows = numRows;
      this.numCols = numCols;
      Moon.__super__.constructor.call(this);
      this.cellWidth = (this.numRows + 1) / this.height;
      this.cellHeight = (this.numCols + 1) / this.width;
      this.geometry = new THREE.PlaneGeometry(this.width, this.height, this.numRows, this.numCols);
      this.geometry.dynamic = true;
      img = new Image();
      img.onload = __bind(function() {
        var planeTex, planeTex2, vertex, _i, _len, _ref;
        this.heights = this.getHeightData(img);
        _ref = this.geometry.vertices;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          vertex = _ref[_i];
          vertex.y = this.heights[_i];
        }
        this.geometry.computeFaceNormals();
        planeTex = THREE.ImageUtils.loadTexture("public/moon.jpeg");
        planeTex.wrapS = planeTex.wrapT = THREE.RepeatWrapping;
        planeTex.repeat.set(10, 10);
        planeTex2 = THREE.ImageUtils.loadTexture("public/map.jpeg");
        this.material = new THREE.MeshLambertMaterial({
          map: planeTex,
          transparent: true,
          opacity: 0.5,
          shading: THREE.SmoothShading
        });
        this.material2 = new THREE.MeshLambertMaterial({
          map: planeTex2,
          transparent: true,
          opacity: 1,
          shading: THREE.SmoothShading
        });
        this.mesh = THREE.SceneUtils.createMultiMaterialObject(this.geometry, [this.material2, this.material]);
        return this.add(this.mesh);
      }, this);
      img.src = 'public/map.jpeg';
    }
    Moon.prototype.getHeight = function(x, z) {
      var col0, col1, gridX, gridZ, h00, h01, h10, h11, height, row0, row1, tx, txty, ty;
      if (!this.heights) {
        return 0;
      }
      x += this.numCols * this.cellWidth * 0.5;
      z += this.numRows * this.cellHeight * 0.5;
      gridX = x / this.cellWidth;
      gridZ = z / this.cellHeight;
      col0 = Math.floor(gridX);
      row0 = Math.floor(gridZ);
      col1 = col0 + 1;
      row1 = row0 + 1;
      if (col1 > this.numCols) {
        col1 = 0;
      }
      if (row1 > this.numRows) {
        row1 = 0;
      }
      h00 = this.heights[col0 + row0 * (this.numCols + 1)];
      h01 = this.heights[col1 + row0 * (this.numCols + 1)];
      h11 = this.heights[col1 + row1 * (this.numCols + 1)];
      h10 = this.heights[col0 + row1 * (this.numCols + 1)];
      tx = gridX - col0;
      ty = gridZ - row0;
      txty = tx * ty;
      height = h00 * (1 - ty - tx + txty) + h01 * (tx - txty) + h11 * txty + h10 * (ty - txty);
      return height;
    };
    Moon.prototype.getHeightData = function(img) {
      var all, canvas, context, data, i, imgd, j, pic, pix, size, _len, _step;
      canvas = document.createElement('canvas');
      canvas.width = 128;
      canvas.height = 128;
      context = canvas.getContext('2d');
      size = 128 * 128;
      data = new Float32Array(size);
      context.drawImage(img, 0, 0);
      imgd = context.getImageData(0, 0, 128, 128);
      pix = imgd.data;
      j = 0;
      for (i = 0, _len = pix.length, _step = 4; i < _len; i += _step) {
        pic = pix[i];
        all = pic + pix[i + 1] + pix[i + 2];
        data[j++] = all / 30;
      }
      return data;
    };
    return Moon;
  })();
}).call(this);
