(function(t){function e(e){for(var a,r,s=e[0],l=e[1],c=e[2],u=0,d=[];u<s.length;u++)r=s[u],i[r]&&d.push(i[r][0]),i[r]=0;for(a in l)Object.prototype.hasOwnProperty.call(l,a)&&(t[a]=l[a]);p&&p(e);while(d.length)d.shift()();return o.push.apply(o,c||[]),n()}function n(){for(var t,e=0;e<o.length;e++){for(var n=o[e],a=!0,r=1;r<n.length;r++){var s=n[r];0!==i[s]&&(a=!1)}a&&(o.splice(e--,1),t=l(l.s=n[0]))}return t}var a={},r={app:0},i={app:0},o=[];function s(t){return l.p+"chemvue/js/"+({about:"about"}[t]||t)+"."+{about:"1a996370"}[t]+".js"}function l(e){if(a[e])return a[e].exports;var n=a[e]={i:e,l:!1,exports:{}};return t[e].call(n.exports,n,n.exports,l),n.l=!0,n.exports}l.e=function(t){var e=[],n={about:1};r[t]?e.push(r[t]):0!==r[t]&&n[t]&&e.push(r[t]=new Promise(function(e,n){for(var a="chemvue/css/"+({about:"about"}[t]||t)+"."+{about:"d5ce3ead"}[t]+".css",i=l.p+a,o=document.getElementsByTagName("link"),s=0;s<o.length;s++){var c=o[s],u=c.getAttribute("data-href")||c.getAttribute("href");if("stylesheet"===c.rel&&(u===a||u===i))return e()}var d=document.getElementsByTagName("style");for(s=0;s<d.length;s++){c=d[s],u=c.getAttribute("data-href");if(u===a||u===i)return e()}var p=document.createElement("link");p.rel="stylesheet",p.type="text/css",p.onload=e,p.onerror=function(e){var a=e&&e.target&&e.target.src||i,o=new Error("Loading CSS chunk "+t+" failed.\n("+a+")");o.request=a,delete r[t],p.parentNode.removeChild(p),n(o)},p.href=i;var f=document.getElementsByTagName("head")[0];f.appendChild(p)}).then(function(){r[t]=0}));var a=i[t];if(0!==a)if(a)e.push(a[2]);else{var o=new Promise(function(e,n){a=i[t]=[e,n]});e.push(a[2]=o);var c,u=document.createElement("script");u.charset="utf-8",u.timeout=120,l.nc&&u.setAttribute("nonce",l.nc),u.src=s(t),c=function(e){u.onerror=u.onload=null,clearTimeout(d);var n=i[t];if(0!==n){if(n){var a=e&&("load"===e.type?"missing":e.type),r=e&&e.target&&e.target.src,o=new Error("Loading chunk "+t+" failed.\n("+a+": "+r+")");o.type=a,o.request=r,n[1](o)}i[t]=void 0}};var d=setTimeout(function(){c({type:"timeout",target:u})},12e4);u.onerror=u.onload=c,document.head.appendChild(u)}return Promise.all(e)},l.m=t,l.c=a,l.d=function(t,e,n){l.o(t,e)||Object.defineProperty(t,e,{enumerable:!0,get:n})},l.r=function(t){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(t,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(t,"__esModule",{value:!0})},l.t=function(t,e){if(1&e&&(t=l(t)),8&e)return t;if(4&e&&"object"===typeof t&&t&&t.__esModule)return t;var n=Object.create(null);if(l.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:t}),2&e&&"string"!=typeof t)for(var a in t)l.d(n,a,function(e){return t[e]}.bind(null,a));return n},l.n=function(t){var e=t&&t.__esModule?function(){return t["default"]}:function(){return t};return l.d(e,"a",e),e},l.o=function(t,e){return Object.prototype.hasOwnProperty.call(t,e)},l.p="/static/",l.oe=function(t){throw console.error(t),t};var c=window["webpackJsonp"]=window["webpackJsonp"]||[],u=c.push.bind(c);c.push=e,c=c.slice();for(var d=0;d<c.length;d++)e(c[d]);var p=u;o.push([0,"chunk-vendors"]),n()})({0:function(t,e,n){t.exports=n("56d7")},4270:function(t,e,n){"use strict";var a=n("44b7"),r=n.n(a);r.a},"44b7":function(t,e,n){},"53f4":function(t,e,n){},"56d7":function(t,e,n){"use strict";n.r(e);n("cadf"),n("551c"),n("097d");var a=n("2b0e"),r=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("v-app",[a("v-navigation-drawer",{attrs:{persistent:"",width:"200","mini-variant":t.miniVariant,clipped:t.clipped,"enable-resize-watcher":"",fixed:"",absolute:"",app:""},model:{value:t.drawer,callback:function(e){t.drawer=e},expression:"drawer"}},[a("v-list",t._l(t.items,function(e,n){return a("v-list-tile",{key:n,attrs:{to:e.path}},[a("v-list-tile-action",[a("v-icon",{domProps:{innerHTML:t._s(e.icon)}})],1),a("v-list-tile-content",[a("v-list-tile-title",{domProps:{textContent:t._s(e.title)}})],1)],1)}),1)],1),a("v-toolbar",{attrs:{app:"","clipped-left":t.clipped,dark:"",color:"primary",height:"70",absolute:""}},[a("v-toolbar-side-icon",{on:{click:function(e){e.stopPropagation(),t.drawer=!t.drawer}}}),a("v-btn",{attrs:{icon:""},on:{click:function(e){e.stopPropagation(),t.miniVariant=!t.miniVariant}}},[a("v-icon",{domProps:{innerHTML:t._s(t.miniVariant?"chevron_right":"chevron_left")}})],1),a("div",{staticClass:"brand-icon ma-2 pt-1"},[a("img",{attrs:{src:n("80e2"),alt:""}})]),a("v-toolbar-title",{domProps:{textContent:t._s(t.title)}}),a("v-spacer"),a("div",{staticClass:"brand-icon ma-2 pt-1"},[t._v("Ò\n            "),a("a",{attrs:{href:"/"}},[a("img",{attrs:{src:n("b79b"),alt:""}})])])],1),t.splashScreen?a("div",{staticClass:"loader-background",attrs:{id:"GladosMainSplashScreen"}},[a("div",{staticClass:"card splash-card z-depth-0"},[a("div",{staticClass:"loader-container"},[a("div",{staticClass:"spinner"},[a("div",{staticClass:"ball ball-1"}),a("div",{staticClass:"ball ball-2"}),a("div",{staticClass:"ball ball-3"}),a("div",{staticClass:"ball ball-4"}),a("div",{staticClass:"ball ball-5"}),a("div",{staticClass:"ball ball-6"})]),a("span",{staticClass:"chembl-logo center-align"},[t._v("ChEMBL")]),a("span",{staticClass:"center-align loading-msg"},[t._v("Loading...")])])])]):t._e(),a("v-content",[a("router-view")],1)],1)},i=[],o={data:function(){return{topval:"10px",splashScreen:!1,clipped:!1,drawer:!0,fixed:!1,items:[{icon:"home",title:"Home",path:"/"},{icon:"low_priority",title:"Test",path:"/test"}],miniVariant:!0,right:!1,rightDrawer:!1,title:"UNICHEM"}},temp_proteins:[],name:"App"},s=o,l=(n("4270"),n("2877")),c=Object(l["a"])(s,r,i,!1,null,"1ca6dec9",null),u=c.exports,d=n("8c4f"),p=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("v-container",[n("v-layout",{attrs:{"align-start":"","justify-start":"",column:""}},[n("h1",[t._v("ChEMBL")]),n("h3",[t._v("Substructure Similarity Search")]),n("v-container",[n("v-layout",{attrs:{"align-center":"","justify-center":""}},[n("v-textarea",{attrs:{name:"input-7-1",label:"CTAB",value:"",hint:"Place your CTAB here"},model:{value:t.ctabText,callback:function(e){t.ctabText=e},expression:"ctabText"}}),n("v-btn",{attrs:{fab:"",dark:"",color:"primary"},on:{click:t.loadCompounds}},[n("v-icon",{attrs:{dark:""}},[t._v("add")])],1)],1),t.isLoading?n("v-progress-circular",{attrs:{size:70,width:7,color:"purple",indeterminate:""}}):t._e(),n("v-layout",{attrs:{"align-space-around":"","justify-center":"",column:"","fill-height":""}},t._l(t.similarCompounds,function(e,a){return n("v-card",{key:a,staticClass:"mt-3",attrs:{compound:e,raised:""}},[n("v-card-title",{attrs:{"primary-title":""}},[n("div",[n("h3",{staticClass:"headline mb-0"},[t._v(t._s(e.n_parent))]),"undefined"!==typeof e.inchikey?n("div",[t._v(t._s(e.inchikey))]):t._e()]),n("v-layout",{attrs:{"align-center":"","justify-end":"",row:"","fill-height":""}},[n("v-btn",{staticClass:"ml-4",attrs:{fab:"",dark:"",small:""},on:{click:function(t){e.show=!e.show}}},[n("v-icon",[t._v("mdi-arrow-down-drop-circle")])],1)],1)],1),n("v-card-actions",[n("transition",{attrs:{name:"slide-fade"}},[e.show?n("div",{staticClass:"detail pa-3"},[n("v-layout",{attrs:{"align-center":"","justify-space-around":"",row:""}},[n("div",{staticClass:"property px-3 py-1"},[n("div",{staticClass:"label"},[t._v("SMILES")]),"undefined"!==typeof e.smiles?n("div",{staticClass:"value"},[t._v(t._s(e.smiles))]):t._e()])])],1):t._e()])],1)],1)}),1)],1)],1)],1)},f=[],m=a["default"].component("Home",{data:function(){return{page:1,ctabText:""}},created:function(){this.$store.commit("SET_LOADING",!1)},computed:{similarCompounds:function(){return this.$store.getters.similarCompounds},isLoading:function(){return this.$store.getters.isLoading}},methods:{loadCompounds:function(){this.$store.commit("SET_LOADING",!0);var t=this.ctabText;this.$store.dispatch("loadCountries",{body:t}),console.log("LOADING... ",this.$store.state.loading)}},watch:{similarCompounds:function(){console.log("CHanged similarCompounds")}}}),v=m,h=Object(l["a"])(v,p,f,!1,null,"022640e5",null),b=h.exports;a["default"].use(d["a"]);var g=new d["a"]({mode:"history",base:"/static/",routes:[{path:"/",name:"Home",component:b},{path:"/test",name:"HelloWorld",component:function(){return n.e("about").then(n.bind(null,"fdab"))}}]}),y=n("2f62"),C=n("bc3a"),_=n.n(C),w=function(){return _.a.create({baseURL:"http://localhost:8000/api",withCredentials:!1,headers:{Accept:"application/json","Content-Type":"application/json"}})};a["default"].use(y["a"]);var S=new y["a"].Store({state:{loading:!0,similarCompounds:[]},mutations:{SET_LOADING:function(t,e){t.loading=e},SET_SIMILAR_COMPOUNDS:function(t,e){e.map(function(t){return t.show=!1,t}),t.similarCompounds=e}},actions:{loadCountries:function(t,e){var n=t.commit,a=e.body;console.log(a),n("SET_LOADING",!0),console.log("State loading ",this.state.loading),w().post("/test",a).then(function(t){n("SET_SIMILAR_COMPOUNDS",t.data),n("SET_LOADING",!1)}).catch(function(t){return console.log(t)})}},getters:{similarCompounds:function(t){return t.similarCompounds},isLoading:function(t){return t.loading}}}),T=n("ce5b"),x=n.n(T);n("53f4");a["default"].use(_.a),a["default"].use(x.a,{theme:{primary:"#07979b",secondary:"#4d5456",accent:"#0e595f",error:"#FF5252",info:"#2196F3",success:"#4CAF50",warning:"#FFC107"}}),a["default"].config.productionTip=!1,new a["default"]({router:g,store:S,render:function(t){return t(u)}}).$mount("#app")},"80e2":function(t,e,n){t.exports=n.p+"chemvue/img/unichem_logo.0475e292.png"},b79b:function(t,e,n){t.exports=n.p+"chemvue/img/chembl_logo_pink.24d6202c.png"}});
//# sourceMappingURL=app.c25521f3.js.map