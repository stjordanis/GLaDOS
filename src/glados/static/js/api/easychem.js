/*
 easyChem. v0.7.28 2015-09-01 by PeterWin
*/
function Point(d, c) {
    if (d === undefined) {
        return this.x = this.y = 0
    }
    if (typeof d == "object" && ("x" in d) && ("y" in d)) {
        this.x = +d.x;
        this.y = +d.y
    } else {
        this.x = +d;
        if (isNaN(this.y = +c)) {
            this.y = this.x
        }
    }
    if (isNaN(this.x) || isNaN(this.y)) {
        this.x = this.y = 0
    }
}

function is0(a) {
    return Math.abs(a) < 0.001
}

function esc(a) {
    return a.replace(/</g, "&lt;").replace(/>/g, "&gt;")
}
Point.prototype = new function() {
    function b(d, c) {
        if (d instanceof Point) {
            return d
        }
        return new Point(d, c)
    }
    this.init = function(c, d) {
        this.x = c;
        this.y = d
    };
    this.equals = function(d, c) {
        var e = b(d, c);
        return is0(this.x - e.x) && is0(this.y - e.y)
    };
    this.addi = function(d, c) {
        var e = b(d, c);
        this.x += e.x;
        this.y += e.y;
        return this
    };
    this.addx = function(d, c) {
        var e = new Point(d, c);
        e.x += this.x;
        e.y += this.y;
        return e
    };
    this.subi = function(d, c) {
        var e = b(d, c);
        this.x -= e.x;
        this.y -= e.y;
        return this
    };
    this.subx = function(d, c) {
        var e = new Point(d, c);
        return e.negi().addi(this)
    };
    this.mini = function(d, c) {
        var e = b(d, c);
        this.x = Math.min(this.x, e.x);
        this.y = Math.min(this.y, e.y)
    };
    this.maxi = function(d, c) {
        var e = b(d, c);
        this.x = Math.max(this.x, e.x);
        this.y = Math.max(this.y, e.y)
    };
    this.negi = function() {
        this.x = -this.x;
        this.y = -this.y;
        return this
    };
    this.negx = function() {
        return new Point(this).negi()
    };
    this.muli = function(c) {
        this.x *= c;
        this.y *= c;
        return this
    };
    this.mulx = function(c) {
        return this.clone().muli(c)
    };
    this.lengthSqr = function() {
        return this.x * this.x + this.y * this.y
    };
    this.length = function() {
        return Math.sqrt(this.lengthSqr())
    };
    this.distSqr = function(d, c) {
        return this.subx(b(d, c)).lengthSqr()
    };
    this.dist = function(d, c) {
        return Math.sqrt(this.distSqr(d, c))
    };
    this.fromRad = function(c) {
        this.x = Math.cos(c);
        this.y = Math.sin(c);
        return this
    };
    this.fromDeg = function(c) {
        return this.fromRad(Math.PI * c / 180)
    };
    this.transponi = function() {
        var c = this.x;
        this.x = this.y;
        this.y = c;
        return this
    };
    this.transponx = function() {
        return this.clone().transponi()
    };

    function a(c) {
        c = Math.round(c * 1000) / 1000;
        return c.toString()
    }
    this.toString = function() {
        return "{" + a(this.x) + ", " + a(this.y) + "}"
    };
    this.clone = function() {
        return new Point(this)
    };
    this.polarAngle = function() {
        if (this.x == 0 && this.y == 0) {
            return 0
        }
        if (this.x == 0) {
            return this.y > 0 ? Math.PI / 2 : Math.PI * 3 / 2
        }
        return Math.atan2(this.y, this.x)
    }
};

function ChemElem(c, b, a) {
    this.n = c;
    this.id = b;
    this.M = a
}

function ChemExpr() {
    this.entities = [];
    this.error = null
}

function ChemOp(a, b, c) {
    this.srcText = a;
    this.dstText = b;
    this.eq = !!c;
    this.commentPre = "";
    this.commentPost = ""
}

function ChemAgent() {
    this.k = 1;
    this.nodes = [];
    this.links = []
}

function ChemNode() {
    this.items = []
}

function ChemLink(a) {
    this.bLinear = false;
    this.bHoriz = false;
    this.text = a;
    this.N = 1;
    this.nodes = [null, null];
    this.color = null
}

function ChemNodeItem(a) {
    this.obj = a;
    this.n = 1;
    this.charge = null;
    this.M = null;
    this.color = null;
    this.atomColor = null
}

function ChemObjGroup(a) {
    this.beg = a;
    this.end = this.findEnd(a);
    this.items = []
}

function ChemObjCustom(a) {
    this.text = a
}

function ChemObjComm(a) {
    this.srcText = a;
    this.text = ChemSys.cvtComm(a)
}
var MenTbl = {},
    MenTblArray = [];
var MenTblCategoryBlock = {
        s_block: "H,Na,K,Rb,Cs,Fr",
        p_block: "B,Al,Ga,In,Tl",
        d_block: "Sc,Y,Hf,Rf",
        f_block: "La,Ac"
    },
    MenTblCategoryProps = {
        "Alkali-metals": "Li,Na,K,Rb,Cs,Fr",
        "Alkaline-earth-metals": "Be,Mg,Ca,Sr,Ba,Ra",
        Lanthanides: "La",
        Actinides: "Ac",
        "Transition-metals": "Sc,Y,Hf,Rf,Cn",
        "Post-transition-metals": "Al,Ga,In,Tl",
        Metalloids: "B,Si,Ge,Sb",
        "Other-nonmetals": "H,C,P,Se",
        Halogens: "F,Cl,Br,I,At",
        "Noble-gases": "He,Ne,Ar,Kr,Xe,Rn",
        "Unknown-props": "Mt"
    },
    MenTblSubGroup = {
        subgr_a: "H,Ga,In,Tl",
        subgr_b: "Sc,Y,La,Ac"
    };
var ChemSys = new function() {
        this.macros = {};
        var E, C, l, o = Math.PI / 6;
        var y = document.defaultView;
        if (!y) {
            y = {}
        }
        if (!y.getComputedStyle) {
            y.getComputedStyle = function(i, j) {
                return i.currentStyle
            }
        }
        this.ver = function() {
            return [0, 7, 28]
        };
        this.verStr = function() {
            return this.ver().join(".")
        };
        this.Clone = function(j) {
            if (typeof j != "object" || j === null) {
                return j
            }
            var i, L = j instanceof Array ? [] : {};
            for (i in j) {
                L[i] = this.Clone(j[i])
            }
            return L
        };

        function r(i, j) {
            this.msgId = i;
            this.params = j;
            this.getMessage = function() {
                return M(this.msgId, this.params)
            };
            this.message = this.getMessage()
        }

        function p(i) {
            return MenTbl[i]
        }
        this.findElem = p;
        var A = {};
        this.findCategory = function(S, T, R) {
            if (!A[S]) {
                var P, O, N, Q, U = A[S] = {},
                    L = {};
                for (N in S) {
                    P = S[N].split(",");
                    for (O in P) {
                        L[P[O]] = N
                    }
                }
                for (N in MenTbl) {
                    O = MenTbl[N].id;
                    if (L[O]) {
                        Q = L[O]
                    }
                    U[O] = Q
                }
            }
            var V = A[S][T];
            if (R !== undefined) {
                if (!R || !(R in this.Dict)) {
                    R = this.curLang
                }
                if (!(R in this.Dict)) {
                    R = "en"
                }
                V = V.replace(/-/g, " ").replace(/_/g, "-");
                V = M(V)
            }
            return V
        };
        ChemElem.prototype = {
            walk: function(i) {
                if (i.atom) {
                    i.atom(this)
                }
            }
        };
        GroupBrackets = {
            "(": ")",
            "[": "]"
        };
        ChemObjGroup.prototype = {
            findEnd: function(i) {
                return GroupBrackets[i]
            },
            walk: function(L) {
                if (L.groupPre) {
                    L.groupPre(this)
                }
                for (var j in this.items) {
                    this.items[j].walk(L)
                }
                if (L.groupPost) {
                    L.groupPost(this)
                }
            }
        };
        ChemObjCustom.prototype = {
            walk: function(i) {
                if (i.custom) {
                    i.custom(this)
                }
            }
        };
        ChemObjComm.prototype = {
            walk: function(i) {
                if (i.comm) {
                    i.comm(this)
                }
            }
        };
        ChemNodeItem.prototype = {
            walk: function(i) {
                if (i.itemPre) {
                    i.itemPre(this)
                }
                this.obj.walk(i);
                if (i.itemPost) {
                    i.itemPost(this)
                }
            }
        };
        ChemNode.prototype = {
            walk: function(L) {
                var j, N = this.items;
                for (j in N) {
                    N[j].walk(L)
                }
            }
        };
        ChemLink.prototype = {};
        ChemOp.prototype = {
            isLinear: function() {
                return true
            },
            walk: function(i) {
                if (i.operation) {
                    i.operation(this)
                }
            }
        };
        ChemAgent.prototype = {
            isLinear: function() {
                for (var j in this.links) {
                    if (!this.links[j].bLinear) {
                        return false
                    }
                }
                return true
            },
            getKoeff: function() {
                return this.k
            },
            setKoeff: function(i) {
                this.k = i
            },
            walk: function(Q) {
                if (Q.agentPre) {
                    Q.agentPre(this)
                }
                var O, S = this.nodes,
                    j = this.links,
                    R = Q.nodePre,
                    N = Q.nodePost,
                    P = Q.comment;
                if (P && this.commentPre) {
                    Q.comment(this.commentPre, 0)
                }
                for (O in S) {
                    if (R) {
                        Q.nodePre(S[O])
                    }
                    S[O].walk(Q);
                    if (N) {
                        Q.nodePost(S[O])
                    }
                }
                if (Q.link) {
                    for (O in j) {
                        Q.link(j[O])
                    }
                }
                if (P && this.commentPost) {
                    Q.comment(this.commentPost, 1)
                }
                if (Q.agentPost) {
                    Q.agentPost(this)
                }
            }
        };
        ChemExpr.prototype = {
            isOk: function() {
                return !this.error
            },
            isLinear: function() {
                for (var j in this.entities) {
                    if (!this.entities[j].isLinear()) {
                        return false
                    }
                }
                return true
            },
            getMessage: function() {
                return this.error ? this.error.getMessage() : null
            },
            walk: function(N) {
                var L, P = this.entities,
                    O = N.entityPre,
                    j = N.entityPost;
                for (L in P) {
                    if (O) {
                        N.entityPre(P[L])
                    }
                    P[L].walk(N);
                    if (j) {
                        N.entityPost(P[L])
                    }
                }
            },
            html: function() {
                var i = new ChemSys.HtmlTempl();
                this.walk(i);
                return i.res
            }
        };
        this.isAbstract = function(L) {
            function j(N) {
                if (typeof N != "number") {
                    throw 1
                }
            }
            try {
                L.walk({
                    agentPre: function(N) {
                        j(N.k)
                    },
                    itemPre: function(N) {
                        j(N.n)
                    }
                });
                return false
            } catch (i) {
                return true
            }
        };
        this.calcMass = function(N) {
            var L = 0,
                j = [0],
                i = [];
            N.walk({
                entityPre: function() {
                    j = [0]
                },
                atom: function(O) {
                    L = O.M
                },
                custom: function() {
                    L = 0
                },
                comm: function() {
                    L = 0
                },
                groupPre: function() {
                    j.unshift(0)
                },
                groupPost: function() {
                    L = j.shift()
                },
                itemPost: function(O) {
                    if (O.M) {
                        L = O.M
                    }
                    j[0] += L * O.n
                },
                agentPost: function(O) {
                    j[0] *= O.k
                },
                entityPost: function() {
                    i.push(ChemSys.massRound(j[0]))
                }
            });
            if (i.length == 0) {
                i[0] = ChemSys.massRound(j[0])
            }
            return i
        };
        this.makeBruttoKey = function(j) {
            if (typeof j == "string") {
                j = this.compile(j);
                if (!j.isOk() || this.isAbstract(j)) {
                    return false
                }
            }
            if (typeof j != "object" || !j.walk) {
                return false
            }
            var i = this.makeBrutto(j, "hill", 1).html();
            return i.replace(/\s/g, "").replace(/<[-\/a-z=\"]*>/g, "")
        };
        this.makeBrutto = function(N, L, j) {
            var i = new ChemExpr();
            N.walk({
                operation: function(O) {
                    i.entities.push(O)
                },
                agentPre: function(U) {
                    var Q = new ChemAgent(),
                        S = new ChemNode(),
                        R;
                    i.entities.push(Q);
                    Q.nodes.push(S);
                    var P, O = ChemSys.groupElements(U),
                        V;
                    for (P in O) {
                        if (P.charAt(0) == "{") {
                            if (!j) {
                                V = new ChemObjCustom(P.substring(1, P.length - 1))
                            } else {
                                continue
                            }
                        } else {
                            V = MenTbl[P]
                        }
                        S.items.push(R = new ChemNodeItem(V));
                        R.n = O[P]
                    }
                    var T = !!O.C;
                    if (L) {
                        S.items.sort(function(aa, Z) {
                            var X = aa.obj,
                                W = Z.obj;
                            var ac = X.id ? X.id : "z" + X.text;
                            var ab = W.id ? W.id : "z" + W.text;
                            if (L == "hill") {
                                if (ac == ab) {
                                    return 0
                                }
                                if (ac == "C") {
                                    return -1
                                }
                                if (ab == "C") {
                                    return 1
                                }
                                if (ac == "H") {
                                    return -1
                                }
                                if (ab == "H") {
                                    return 1
                                }
                                return ac < ab ? -1 : 1
                            } else {
                                if (L == "mass") {
                                    function Y(ag) {
                                        var af = ag.M || ag.obj.M || 0
                                    }
                                    var ae = Y(X),
                                        ad = Y(W);
                                    if (ae == ad) {
                                        return 0
                                    }
                                    return ae < ad ? -1 : 1
                                } else {
                                    if (ac < ab) {
                                        return -1
                                    }
                                    if (ac > ab) {
                                        return 1
                                    }
                                    return 0
                                }
                            }
                        })
                    }
                }
            });
            return i
        };

        function f(P, N, i) {
            var L, O;
            for (L in N) {
                O = N[L] * i;
                if (!P[L]) {
                    P[L] = O
                } else {
                    P[L] += O
                }
            }
        }
        this.merge = f;
        this.groupElements = function(j) {
            var i = [{}];
            j.walk({
                itemPre: function(L) {
                    i.unshift({})
                },
                atom: function(L) {
                    i[0][L.id] = 1
                },
                custom: function(L) {
                    if (L.text) {
                        i[0]["{" + L.text + "}"] = 1
                    }
                },
                itemPost: function(L) {
                    f(i[1], i[0], L.n);
                    i.shift()
                }
            });
            return i[0]
        };
        this.sortGroup = function(j, O) {
            var N, L = [];
            for (N in j) {
                L.push({
                    id: N,
                    n: j[N]
                })
            }
            L.sort(function(Q, P) {
                var i = MenTbl[Q.id],
                    R = MenTbl[P.id];
                if (i.n < R.n) {
                    return -1
                }
                if (i.n > R.n) {
                    return 1
                }
                return 0
            });
            return L
        };
        this.rulesBB = {
            AgentK: "[b]*[/b]",
            ItemCnt: "[sub]*[/sub]",
            ItemMass: "[sup]*[/sup]",
            ItemCharge: "[sup]*[/sup]",
            ColorPre: "[color=*]",
            ColorPost: "[/color]",
            NodeCharge: "[sup]*[/sup]",
            Custom: "[i]*[/i]",
            Comment: "[color=blue]*[/color]"
        };
        this.rulesHtml = {
            Atom: "",
            AgentK: "<b>*</b>",
            ItemMass: "<sup>*</sup>",
            ItemCnt: "<sub>*</sub>",
            ItemCharge: '<sup class="echem-item-charge">*</sup>',
            ColorPre: '<span style="color:*">',
            ColorPost: "</span>",
            NodeCharge: "<sup>*</sup>",
            Custom: "<i>*</i>",
            Comment: "<em>*</em>",
            OpComment: '<span class="echem-opcomment">*</span>',
            Operation: '<span class="echem-op">*</span>'
        };

        function q(L, i, j) {
            if (L[i]) {
                return L[i].replace("*", j)
            }
            return j
        }
        this.makeHtml = function(O, N, i) {
            var L = new this.HtmlTempl(N);
            if (i) {
                for (var j in i) {
                    if (L[j]) {
                        L["$" + j] = L[j]
                    }
                    L[j] = i[j]
                }
            }
            O.walk(L);
            return L.res
        };
        this.HtmlTempl = function(j) {
            var i, L;
            j = j || ChemSys.rulesHtml;
            this.res = "";
            this.entityPre = function(N) {
                if (this.res) {
                    this.res += " "
                }
            };
            this.operation = function(O) {
                var N = O.dstText;
                if (O.commentPre) {
                    N = q(j, "OpComment", O.commentPre) + N
                }
                if (O.commentPost) {
                    N += q(j, "OpComment", O.commentPost)
                }
                this.res += q(j, "Operation", N)
            };
            this.agentPre = function(N) {
                i = N;
                L = 0;
                if (N.k != 1) {
                    this.res += q(j, "AgentK", N.k)
                }
            };
            this.drawCharge = function(N, O) {
                if (N.charge && N.charge.left == O) {
                    this.res += q(j, "NodeCharge", N.charge.text)
                }
            };
            this.nodePre = function(N) {
                this.drawCharge(N, 1)
            };
            this.nodePost = function(N) {
                if (L < i.links.length) {
                    this.res += i.links[L].text
                }
                L++;
                this.drawCharge(N, 0)
            };
            this.itemPre = function(N) {
                if (N.color) {
                    this.res += q(j, "ColorPre", N.color)
                }
                if (N.M) {
                    this.res += q(j, "ItemMass", N.M)
                }
                this.lastItem = N
            };
            this.itemPost = function(N) {
                if (N.charge) {
                    this.res += q(j, "ItemCharge", N.charge.text)
                }
                if (N.n != 1) {
                    this.res += q(j, "ItemCnt", N.n)
                }
                if (N.color) {
                    this.res += q(j, "ColorPost", N.color)
                }
            };
            this.atom = function(O) {
                var N = this.lastItem.atomColor;
                if (N) {
                    this.res += q(j, "ColorPre", N)
                }
                this.res += q(j, "Atom", O.id);
                if (N) {
                    this.res += q(j, "ColorPost", N)
                }
            };
            this.groupPre = function(N) {
                this.res += N.beg
            };
            this.groupPost = function(N) {
                this.res += N.end
            };
            this.comm = function(N) {
                this.res += q(j, "Comment", N.text)
            };
            this.custom = function(N) {
                this.res += q(j, "Custom", N.text)
            };
            this.result = function() {
                return this.res
            }
        };
        this.isEmptyNode = function(L) {
            var j = 1;

            function i(N) {
                if (N.text) {
                    j = 0
                }
            }
            L.walk({
                comm: i,
                custom: i,
                atom: function() {
                    j = 0
                }
            });
            return !!j
        };
        this.demoVisitor = function(i) {
            i.walk({
                entityPre: function(j) {},
                entityPost: function(j) {},
                operation: function(j) {},
                agentPre: function(j) {},
                agentPost: function(j) {},
                nodePre: function(j) {},
                nodePost: function(j) {},
                link: function(j) {},
                itemPre: function(j) {},
                itemPost: function(j) {},
                atom: function(j) {},
                groupPre: function(j) {},
                groupPost: function(j) {},
                custom: function(j) {}
            })
        };
        var G = ["H,1.008", "T,3.016", "He,4.003", "Li,6.941", "Be,9.0122", "B,10.811", "C,12.011", "N,14.007", "O,15.999", "F,18.998", "Ne,20.179", "Na,22.99", "Mg,24.312", "Al,26.092", "Si,28.086", "P,30.974", "S,32.064", "Cl,35.453", "Ar,39.948", "K,39.102", "Ca,40.08", "Sc,44.956", "Ti,47.956", "V,50.941", "Cr,51.996", "Mn,54.938", "Fe,55.849", "Co,58.933", "Ni,58.7", "Cu,63.546", "Zn,65.37", "Ga,69.72", "Ge,72.59", "As,74.922", "Se,78.96", "Br,79.904", "Kr,83.8", "Rb,85.468", "Sr,87.62", "Y,88.906", "Zr,91.22", "Nb,92.906", "Mo,95.94", "Tc,99", "Ru,101.07", "Rh,102.906", "Pd,106.4", "Ag,107.868", "Cd,112.41", "In,114.82", "Sn,118.69", "Sb,121.75", "Te,127.6", "I,126.905", "Xe,131.3", "Cs,132.905", "Ba,137.34", "La,138.906", "Ce,140.115", "Pr,140.908", "Nd,144.24", "Pm,145", "Sm,150.4", "Eu,151.96", "Gd,157.25", "Tb,158.926", "Dy,162.5", "Ho,164.93", "Er,167.26", "Tm,168.934", "Yb,173.04", "Lu,174.97", "Hf,178.49", "Ta,180.948", "W,183.85", "Re,186.207", "Os,190.2", "Ir,192.22", "Pt,195.09", "Au,196.967", "Hg,200.59", "Tl,204.37", "Pb,207.19", "Bi,208.98", "Po,210", "At,210", "Rn,222", "Fr,223", "Ra,226", "Ac,227", "Th,232.038", "Pa,231", "U,238.29", "Np,237", "Pu,244", "Am,243", "Cm,247", "Bk,247", "Cf,251", "Es,254", "Fm,257", "Md,258", "No,259", "Lr,260", "Rf,261", "Db,262", "Sg,271", "Bh,267", "Hs,269", "Mt,276", "Ds,281", "Rg,280", "Cn,285"];
        this.massRound = function(i) {
            if (!i) {
                return i
            }
            return Math.floor(i * 1000) / 1000
        };
        var m = [{
            op: "+"
        }, {
            op: "-->",
            eq: 1,
            dst: "—→"
        }, {
            op: "->",
            eq: 1,
            dst: "→"
        }, {
            op: "®",
            eq: 1,
            dst: "→"
        }, {
            op: "→",
            eq: 1
        }, {
            op: "=",
            eq: 1
        }, {
            op: "↔",
            eq: 1
        }, {
            op: "<->",
            eq: 1,
            dst: "↔"
        }, {
            op: "<=>",
            eq: 1,
            dst: "\u21CC"
        }, {
            op: "*",
            dst: "∙"
        }, {
            op: "!=",
            dst: "≠"
        }];
        for (E = 0; E < G.length; E++) {
            l = G[E].split(",");
            MenTblArray.push(MenTbl[l[0]] = new ChemElem(+E + 1, l[0], +l[1]))

        }

        function n(i) {
            if (i === undefined) {
                return null
            }
            return i.length == 0 ? null : i[i.length - 1]
        }
        var e = [
            [/\|\^|ArrowUp/g, "↑"],
            [/(\|v)|(ArrowDown)/g, "↓"],
            [/\^o/g, "°"]
        ];
        var J = {
            alpha: "α",
            Alpha: "Α",
            beta: "β",
            Beta: "Β",
            gamma: "γ",
            Gamma: "Γ",
            delta: "δ",
            Delta: "Δ",
            epsilon: "ε",
            Epsilon: "Ε",
            zeta: "ζ",
            Zeta: "Ζ",
            eta: "η",
            Eta: "Η",
            theta: "θ",
            Theta: "Θ",
            iota: "ι",
            Iota: "Ι",
            kappa: "κ",
            Kappa: "Κ",
            lambda: "λ",
            Lambda: "Λ",
            mu: "μ",
            Mu: "Μ",
            nu: "ν",
            Nu: "Ν",
            xi: "ξ",
            Xi: "Ξ",
            omicron: "ο",
            Omicron: "Ο",
            pi: "π",
            Pi: "Π",
            rho: "ρ",
            Rho: "Ρ",
            sigma: "σ",
            Sigma: "Σ",
            tau: "τ",
            Tau: "Τ",
            upsilon: "υ",
            Upsilon: "Υ",
            phi: "φ",
            Phi: "Φ",
            chi: "χ",
            Chi: "Χ",
            psi: "ψ",
            Psi: "Ψ",
            omega: "ω",
            Omega: "Ω"
        };

        function h(j) {
            var P, S, O = j,
                R, N, Q, L;
            for (P in e) {
                S = e[P];
                O = O.replace(S[0], S[1])
            }
            P = 0;
            while (P < O.length) {
                R = O.indexOf("[", P);
                if (R < 0) {
                    break
                }
                N = O.indexOf("]", R);
                if (N < 0) {
                    break
                }
                Q = O.substring(R + 1, N);
                L = J[Q];
                if (L) {
                    O = O.substr(0, R) + L + O.substr(N + 1)
                } else {
                    P = R + 1
                }
            }
            return u(O)
        }
        this.cvtComm = h;

        function u(i) {
            E = i.indexOf("`");
            while (E >= 0) {
                k = i.indexOf("`", E + 1);
                if (k < 0) {
                    break
                }
                s = i.substring(E + 1, k);
                t = M(s);
                if (t == s) {
                    i = i.substring(0, E) + i.substring(E + 1)
                } else {
                    i = i.substring(0, E) + t + i.substring(k + 1)
                }
                E = i.indexOf("`")
            }
            i = i.replace("`", "");
            return i
        }
        this.translate = u;
        var b = {
            i: 1,
            ii: 2,
            iii: 3,
            iv: 4,
            v: 5,
            vi: 6,
            vii: 7,
            viii: 8
        };

        function d(L) {
            var i, j, O = 0;

            function N(P) {
                return {
                    val: P,
                    text: L,
                    left: 0
                }
            }
            L = L.replace(/–/g, "-");
            if (L) {
                if (/^-+$/.test(L)) {
                    return N(-L.length)
                }
                if (/^\++$/.test(L)) {
                    return N(L.length)
                }
                if (/(^|(^[-+]))\d+$/.test(L)) {
                    return N(+L)
                }
                if (/^\d+[-+]$/.test(L)) {
                    i = L.length - 1;
                    j = +(L.substring(0, i));
                    if (L.charAt(i) == "-") {
                        j = -j
                    }
                    return N(j)
                }
                j = b[L];
                if (j) {
                    L = L.toUpperCase();
                    return N(j)
                }
            }
            return null
        }
        var c = {
            "$32": Math.sqrt(3) / 2,
            "$3": Math.sqrt(3),
            "$3x2": Math.sqrt(3) * 2,
            "$2": Math.sqrt(2),
            "$22": Math.sqrt(2) / 2,
            "$2x2": Math.sqrt(2) * 2,
            "½": 0.5,
            "¼": 1 / 4,
            "¾": 3 / 4,
            "⅓": 1 / 3,
            "⅔": 2 / 3
        };
        var B = {};

        function D(i) {
            if (!i) {
                return 0
            }
            var L = 1;
            if (i.charAt(0) == "-") {
                L = -1;
                i = i.substring(1)
            }
            if (i.charAt(0) == "%") {
                var P, O = i.indexOf(":"),
                    N;
                if (O >= 0) {
                    N = i.substring(1, O);
                    P = i.substring(O + 1);
                    B[N] = P
                } else {
                    N = i.substring(1);
                    P = B[N];
                    if (!P) {
                        throw new Error("Undefined const " + N)
                    }
                }
                i = P
            }
            if (i in c) {
                return L * c[i]
            }
            return +i * L
        }
        var a = {
            "≡": "%",
            "–": "-"
        };
        var w = {
                "-": {
                    N: 1,
                    A: 0,
                    slope: 0
                },
                "=": {
                    N: 2,
                    A: 0,
                    slope: 0
                },
                "%": {
                    N: 3,
                    A: 0,
                    slope: 0,
                    text: "≡"
                },
                "|": {
                    N: 1,
                    A: Math.PI / 2,
                    slope: 0
                },
                "||": {
                    N: 2,
                    A: Math.PI / 2,
                    slope: 0
                },
                "|||": {
                    N: 3,
                    A: Math.PI / 2,
                    slope: 0
                },
                "/": {
                    N: 1,
                    A: 0,
                    slope: -1
                },
                "//": {
                    N: 2,
                    A: 0,
                    slope: -1
                },
                "///": {
                    N: 3,
                    A: 0,
                    slope: -1
                },
                "\\": {
                    N: 1,
                    A: 0,
                    slope: 1
                },
                "\\\\": {
                    N: 2,
                    A: 0,
                    slope: 1
                },
                "\\\\\\": {
                    N: 3,
                    A: 0,
                    slope: 1
                }
            },
            x = {};
        for (E in w) {
            x[E.charAt(0)] = 1
        }
        for (E in a) {
            x[E.charAt(0)] = 1
        }

        function v(i) {
            return w[a[i] || i]
        }
        this.compile = function(ah) {
            ah = ah.replace(/−/g, "-") + " ";
            ah = ah.replace(/\(\*/g, "<").replace(/\*\)/g, ">");
            var aZ, aR = 0,
                aS = "",
                aN, ae = new ChemExpr(),
                aV, az = ae.entities,
                ai, aA = "begin",
                ap = [],
                af = 0,
                Q = null,
                aT, aD, aw, Z, W = [],
                aq = [],
                aU, ay = 0,
                ab = {};

            function ao(a4, i) {
                i = i || {};
                if ("pos" in i) {
                    a4 += " in position [pos]";
                    i.pos = i.pos || aR + 1
                }
                throw new r(a4, i)
            }
            var aI, a1 = null,
                V = null,
                N = null,
                aX = 0,
                aE = null,
                L = 0,
                aH = 1,
                a3 = 0,
                aa = 0,
                O = 0;
            funcs = {
                M: function(i) {
                    a1 = +i
                },
                L: function(i) {
                    aH = D(i) || 1
                },
                color: function(i) {
                    if (i == "") {
                        i = null
                    }
                    V = i
                },
                ver: function(a4) {
                    var a5 = a4.split("."),
                        i = ChemSys.ver();
                    if (a5.length > 1) {
                        if (a5[0] > i[0] || (a5[0] == i[0] && a5[1] > i[1])) {
                            ao("Invalid version", {
                                cur: ChemSys.verStr(),
                                need: a5.join(".")
                            })
                        }
                    }
                },
                dots: function(bd) {
                    var a9, bb, a8 = "",
                        a4, bc = 0,
                        a6 = 0;
                    var a7 = {
                            U: "T",
                            D: "B",
                            u: "t",
                            d: "b"
                        },
                        a5 = {
                            L: 68,
                            R: 136,
                            T: 3,
                            B: 48
                        },
                        ba = {
                            Lt: 64,
                            Lb: 4,
                            Rt: 128,
                            Rb: 8,
                            Tl: 2,
                            Tr: 1,
                            Bl: 32,
                            Br: 16
                        };
                    for (a9 = 0; a9 < bd.length; a9++) {
                        bb = bd.charAt(a9);
                        if (bb in a7) {
                            bb = a7[bb]
                        }
                        a4 = a8 + bb;
                        if (bb in a5) {
                            a6 |= a5[bb];
                            a8 = bb
                        } else {
                            if (a4 in ba) {
                                a6 &= ~ba[a4];
                                a8 = ""
                            } else {
                                if (bb == "!") {
                                    bc = 255
                                }
                            }
                        }
                    }
                    O = a6 ^ bc
                },
                dashes: function(a5) {
                    var a7, a9, a6 = 0,
                        a4 = 0,
                        a8 = 0;
                    aa = 0;
                    for (a7 = 0; a7 < a5.length; a7++) {
                        a9 = a5.charAt(a7);
                        switch (a9) {
                            case ".":
                                a6++;
                                a4++;
                                a8++;
                                break;
                            case "-":
                                aa |= 1;
                                a6++;
                                a4++;
                                a8++;
                                break;
                            case "_":
                                aa |= 2;
                                a6++;
                                a4++;
                                a8++;
                                break;
                            case "|":
                                aa |= a4 ? 8 : 4;
                                a4++;
                                break;
                            case "/":
                                aa |= a6 ? 128 : 16;
                                a6++;
                                break;
                            case "\\":
                                aa |= a8 ? 32 : 64;
                                a8++;
                                break;
                            case "<":
                                aa |= 80;
                                a6++;
                                a8++;
                                break;
                            case ">":
                                aa |= 160;
                                break
                        }
                    }
                },
                itemColor: function(i) {
                    if (i == "") {
                        i = null
                    }
                    N = i;
                    aX = 0
                },
                itemColor1: function(i) {
                    N = i;
                    aX = 1
                },
                atomColor: function(i) {
                    aE = i;
                    L = 0
                },
                atomColor1: function(i) {
                    aE = i;
                    L = 1
                },
                slope: function(i) {
                    i = +i;
                    Q = isNaN(i) ? null : i * Math.PI / 180
                }
            };

            function aO(i, a4) {
                aA = i;
                aV = "";
                return a4 || 0
            }

            function ax() {
                aV += aZ;
                return 1
            }

            function ag() {
                if (aU) {
                    ao("Link required")
                }
            }

            function a2() {
                aT = null;
                Z = null;
                aw = W.length;
                W.push({
                    sc: 0,
                    L: []
                })
            }

            function ad() {
                var a5 = aq.pop();
                if (a5) {
                    ao("Не закрыта ветка", {
                        pos: a5.pos
                    })
                }
                var i = W[aw];
                var a4 = n(i.L);
                if (!a4) {
                    return
                }
                if (!a4.nodes[1]) {
                    a4.nodes[1] = a0(1)
                }
            }

            function a0(a4) {
                ag();
                aT = new ChemNode();
                var a6 = W[aw];
                ap = [aT.items];
                aT.pt = new Point();
                aT.ch = aw;
                aT.sc = a6.sc;
                var a8 = Z,
                    i = a8 ? a8.nodes[0] : null;
                if (a4) {
                    aT.bAuto = 1;
                    if (a8 && a8.bHoriz) {
                        aT.sc = --a6.sc;
                        a8.bHoriz = 0
                    }
                }
                if (a8) {
                    aT.pt = a8.nodes[0].pt.addx(aD);
                    a8.nodes[1] = aT;
                    if (!a8.bHoriz) {
                        aT.sc = i.sc
                    }
                    var a7, a5 = a6.L.length;
                    while (a5 > 0) {
                        a7 = a6.L[--a5].nodes[0];
                        if (a7.sc != aT.sc) {
                            break
                        }
                        if (a7.pt.equals(aT.pt)) {
                            aC(a7);
                            return aT = a7
                        }
                    }
                }
                aT.i = ai.nodes.length;
                ai.nodes.push(aT);
                if (ai.commentPre) {
                    aW(new ChemObjComm(ai.commentPre));
                    ai.commentPre = null
                }
                return aT
            }

            function S(a9) {
                var a7, bb = +a9,
                    a4 = ai.nodes;
                if (bb) {
                    if (bb < 0) {
                        bb += a4.length;
                        if (bb < 0) {
                            return null
                        }
                        return a4[bb]
                    }
                    if (bb > a4.length) {
                        return null
                    }
                    return a4[--bb]
                }
                var a5, ba, a6 = a9,
                    a8;
                if (a8 = p(a6)) {
                    a5 = ai.nodes;
                    bb = a5.length;
                    for (a7 = 0; a7 < bb; a7++) {
                        ba = a5[a7];
                        if (ba.items.length == 1 && ba.items[0].obj == a8) {
                            return ba
                        }
                    }
                }
                ba = ab[a9];
                if (ba) {
                    return ba
                }
                return null
            }

            function X(a4) {
                var i = S(a4);
                if (!i) {
                    ao("Invalid node reference '[ref]'", {
                        ref: a4
                    })
                }
                return i
            }

            function aC(a6) {
                ag();
                var a4 = W[aw];
                var a5 = n(a4.L);
                if (!a5) {
                    aw = a6.ch;
                    W.length--
                } else {
                    var i = a5.nodes[0];
                    a5.nodes[1] = a6;
                    if (i.ch != a6.ch) {
                        R(a6, i)
                    }
                }
                aT = a6
            }

            function R(a7, a5) {
                var a4 = W[aw];
                var a8 = W[a7.ch];
                var be = a7.pt.subx(a5.pt.addx(aD));
                var bc, bb = a4.L,
                    a9, ba = bb.length,
                    a6, bd = a7.sc;
                for (a9 in ai.nodes) {
                    a6 = ai.nodes[a9];
                    a6.ufl = a6.ch != a5.ch
                }
                while (ba > 0) {
                    bc = bb[--ba];
                    for (a9 in bc.nodes) {
                        a6 = bc.nodes[a9];
                        if (a6.ufl) {
                            continue
                        }
                        a6.ufl = 1;
                        a6.ch = a7.ch;
                        a6.pt.addi(be);
                        a6.sc = a7.sc
                    }
                }
                for (ba in bb) {
                    bb[ba].nodes[0].ufl = 0;
                    a8.L.push(bb[ba])
                }
                W[aw] = null;
                aw = a7.ch
            }

            function ak() {
                var a5 = W[aw],
                    a4 = aT,
                    i = Z;
                if (!a4 && !i) {
                    ao("Перед началом ветки необходимо определить узел или связь")
                }
                if (i && !i.nodes[1]) {
                    a0(1)
                }
                aq.push({
                    node: a4,
                    link: i,
                    pos: aR
                });
                aU++
            }

            function aG() {
                var a4 = aq.pop();
                if (!a4) {
                    ao("Лишний символ конца ветки")
                }
                var i = n(W[aw].L);
                if (i && !i.nodes[1]) {
                    a0(1)
                }
                aT = a4.node;
                Z = a4.link;
                if (!aT) {
                    aT = Z.nodes[1]
                }
                aU++
            }
            var P = null,
                aP = new Point();

            function am(a5, a6) {
                aU = 0;
                aP = new Point();
                var a4 = new ChemLink(a6.text);
                a4.N = a6.N;
                a4.slope = a6.slope || 0;
                a4.midPts = P;
                P = null;
                a4.w0 = a6.w0;
                a4.w1 = a6.w1;
                if (a6.arr0) {
                    a4.arr0 = a6.arr0
                }
                if (a6.arr1) {
                    a4.arr1 = a6.arr1
                }
                if (a6.cross) {
                    a4.cross = 1
                }
                if (a6.style) {
                    a4.style = a6.style
                }
                if (!a6.horiz) {
                    a4.bHoriz = is0(a5.y) && aT && !aT.bAuto
                } else {
                    a4.bHoriz = a6.horiz > 0
                }
                a4._horiz = is0(a5.y);
                a4.bLinear = a4.bHoriz && a5.x > 0;
                if (V) {
                    a4.color = V
                }
                a4.nodes[0] = aT;
                var i = W[aw];
                if (!a4.nodes[0]) {
                    a4.nodes[0] = a0(1)
                }
                aD = a5;
                aT = null;
                ai.links.push(a4);
                i.L.push(a4);
                if (a4.bHoriz) {
                    i.sc++
                }
                af = 0;
                Z = a4;
                return a4
            }

            function aJ() {
                W = [];
                aq = [];
                aU = 0;
                ab = {};
                a2();
                a3 = 0;
                ai.part = ay
            }

            function ac() {
                if (ap.length != 1) {
                    ao("Expected '[C]'", {
                        C: n(ap[1]).end
                    })
                }
                ad();
                var a5, a7, a6, a9, a8, bd = ai.links,
                    a4 = ai.nodes,
                    ba = a4.length;

                function i(be, bf) {
                    if (!be.bAuto) {
                        return
                    }
                    be.val = be.val || 0;
                    be.val += bf
                }
                for (a7 in bd) {
                    a9 = bd[a7];
                    for (a5 in a9.nodes) {
                        i(a9.nodes[a5], a9.N)
                    }
                }
                for (a7 in a4) {
                    a6 = a4[a7];
                    if (!a6.bAuto) {
                        continue
                    }
                    a6.items.push(new ChemNodeItem(MenTbl.C));
                    a5 = 4 - a6.val;
                    if (a5 > 0) {
                        a6.items.push(a8 = new ChemNodeItem(MenTbl.H));
                        a8.n = a5
                    }
                }
                var bc = {},
                    bb;
                a7 = 0;
                while (a7 < bd.length) {
                    a9 = bd[a7];
                    bb = [];
                    for (a5 in a9.nodes) {
                        bb.push(a9.nodes[a5].i)
                    }
                    bb.sort();
                    bb = bb.join(";");
                    if (!bc[bb]) {
                        bc[bb] = a9;
                        a7++
                    } else {
                        bc[bb].N += a9.N;
                        bd.splice(a7, 1)
                    }
                }
            }

            function aL() {
                if (aZ >= "A" && aZ <= "Z") {
                    aO("agentElem");
                    return ax()
                }
                if (aZ in x) {
                    return aO("shortLink")
                }
                switch (aZ) {
                    case "#":
                        return aO("nodeRef", 1);
                    case "{":
                        return aO("itemCustom", 1);
                    case "<":
                        ak();
                        return aO("agentMid", 1);
                    case ">":
                        aG();
                        return aO("agentMid", 1);
                    case "(":
                    case "[":
                        var a5 = new ChemObjGroup(aZ);
                        aW(a5);
                        ap.unshift(a5.items);
                        return aO("agentIn", 1);
                    case ")":
                    case "]":
                        if (ap.length <= 1) {
                            ao("Unexpected '[C]'", {
                                C: aZ
                            })
                        }
                        ap.shift();
                        var a4 = n(ap[0]),
                            i = a4 ? a4.obj.end : a4;
                        if (i != aZ) {
                            ao("Expected '[ok]' instead of '[bad]'", {
                                ok: i,
                                bad: aZ
                            })
                        }
                        return aO("itemFinal", 1);
                    case '"':
                        return aO("comm", 1);
                    case "^":
                        return aO("charge", 1);
                    case "`":
                        return aO("negChar", 1);
                    case "_":
                        return aO("fullLink", 1);
                    case ";":
                        ad();
                        a2();
                        return aO("agentSpace", 1);
                    case "$":
                    case "ƒ":
                        return aO("funcName", 1);
                    case ":":
                        return aO("label", 1);
                    case "c":
                        a0(1);
                        return 1
                }
                return -1
            }
            var aK = 0;

            function av(i) {
                ae.entities.push(ai = i);
                if (aK) {
                    ai.commentPre = aK;
                    aK = 0
                }
            }

            function aW(a4) {
                if (!aT) {
                    a0()
                }
                var i = new ChemNodeItem(a4);
                ap[0].push(i);
                i.color = V;
                if (N) {
                    i.color = N;
                    if (aX) {
                        N = null
                    }
                }
                i.atomColor = aE;
                if (L) {
                    aE = null
                }
                if (aa) {
                    i.dashes = aa;
                    aa = 0
                }
                if (O) {
                    i.dots = O;
                    O = 0
                }
                if (af) {
                    i.bCenter = 1
                }
                af = 0
            }

            function aF() {
                return n(ap[0])
            }

            function at() {
                var a4 = m.length - 1;
                while (a4 >= 0 && ah.indexOf(m[a4].op, aR) != aR) {
                    a4--
                }
                if (a4 < 0) {
                    return null
                }
                var a5 = ah.charAt(aR + m[a4].op.length);
                if (!(/[\s\"]/.test(a5))) {
                    return null
                }
                var i = m[a4];
                av(new ChemOp(i.op, i.dst || i.op, i.eq));
                if (ai.commentPre) {
                    ai.commentPre = h(ai.commentPre)
                }
                if (i.eq) {
                    ay++
                }
                aR += i.op.length;
                if (ah[aR] == '"') {
                    return aO("comm", 1)
                }
                return aO("begin")
            }

            function an(a5) {
                var a4 = a5.slope,
                    i = a5.bNeg;
                if (!a4) {
                    if (a5._horiz) {
                        return i ? 9 : 3
                    } else {
                        return i ? 12 : 6
                    }
                }
                if (a4 > 0) {
                    if (a5.bCorr) {
                        return i ? 11 : 5
                    } else {
                        return i ? 10 : 4
                    }
                }
                if (a5.bCorr) {
                    return i ? 7 : 1
                }
                return i ? 8 : 2
            }

            function U(bh, a6) {
                var bk = v(bh),
                    bp, be = {
                        text: bk.text || bh,
                        N: bk.N,
                        slope: bk.slope,
                        horiz: 0
                    };
                if (a6) {
                    for (bp = 0; bp < a6.length; bp++) {
                        switch (a6.charAt(bp)) {
                            case "0":
                                be.N = 0;
                                break;
                            case "v":
                                be.arr1 = 1;
                                be.N = 0;
                                be.style = "|";
                                break;
                            case "w":
                                be.w1 = 1;
                                break;
                            case "d":
                                be.w1 = -1;
                                break;
                            case "h":
                                be.N = 0;
                                be.style = ":";
                                break;
                            case "~":
                                be.style = "~";
                                break;
                            case "x":
                                be.cross = 1;
                                break
                        }
                    }
                }
                var bg = Q || o;
                var bq = bk.A + bk.slope * bg;
                var bc = Z;
                var a7 = 0;
                if (!Q && bc && bc.bAuto) {
                    var bn = an(bc),
                        bm;
                    var a5 = bc.slope,
                        a4 = bk.slope;
                    if (a4 < 0) {
                        bm = af ? 8 : 2
                    } else {
                        if (a4 > 0) {
                            bm = af ? 10 : 4
                        }
                    }
                    if (bk.slope && bc._horiz) {
                        a7 = 1
                    } else {
                        if (((bn == 8 || bn == 7) && bm == 4) || ((bn == 4 || bn == 5) && bm == 8) || ((bn == 10 || bn == 11) && bm == 2) || ((bn == 1 || bn == 2) && bm == 10)) {
                            a7 = 2
                        }
                    }
                    if (a7) {
                        bq = bk.A + bk.slope * Math.PI / 3
                    }
                }
                var bt = af;
                if (af) {
                    bq += Math.PI
                }
                var a8 = new Point().fromRad(bq).muli(aH);
                var a9 = am(a8, be);
                a9.bNeg = bt;
                a9.bAuto = 1;
                if (!Q && bc && bc.bAuto && a9.bAuto && !bc.bCorr) {
                    if (((bn == 4 || bn == 5) && bm == 8) || ((bn == 2 || bn == 1) && bm == 10) || ((bn == 10 || bn == 11) && bm == 2) || ((bn == 8 || bn == 7) && bm == 4) || ((bn == 10 || bn == 8 || bn == 2 || bn == 4) && a9._horiz)) {
                        var ba = a9.nodes[0];
                        var bs = bc.nodes[0].pt;
                        var br = ba.pt.subx(bs);
                        var bj = br.x < 0 ? -1 : 1,
                            bi = br.y < 0 ? -1 : 1;
                        var bu = new Point(Math.abs(br.y) * bj, Math.abs(br.x) * bi);
                        var bb = bu.addi(bs);
                        var bd = bb.subx(ba.pt);
                        bc.bCorr = 100;
                        if (!ba.bFix) {
                            ba.pt = bb;
                            var bf = W[aw].L;
                            var bo = bf.length - 2;
                            while (bf[bo] != bc && bo >= 0) {
                                bf[--bo].nodes[1].ufl = 0
                            }
                            if (bo < bf.length - 2) {
                                while (bo < bf.length - 2) {
                                    var bl = bf[++bo].nodes[1];
                                    if (!bl.ufl) {
                                        bl.ufl = 1;
                                        bl.pt.addi(bd)
                                    }
                                }
                            }
                        } else {}
                    }
                }
                a9.bCorr = a7
            }

            function aj(a7) {
                var a6, a5, a9, a8 = {},
                    a4 = a7.split(",");
                for (a6 in a4) {
                    a9 = a4[a6];
                    if (a9) {
                        a5 = a9.charAt(0);
                        a9 = a9.substring(1);
                        if (!a9) {
                            a9 = true
                        }
                        a8[a5] = a9
                    }
                }
                return a8
            }

            function T(a6, a8, ba) {
                if (!Z) {
                    return new Point(aH, 0)
                }
                if (!Z.nodes[1]) {
                    a0(1)
                }
                var a9 = Z.nodes[1].pt;
                if (!ba) {
                    ba = Z.nodes[0].pt
                }
                var a4 = a9.dist(ba);
                var a5 = Math.PI * 2 / a8;
                var a7 = a9.subx(ba).polarAngle();
                var i = a7 + a6 * a5;
                return new Point().fromRad(i).muli(a4)
            }

            function au(i, a5, a4) {
                am(T(i, a5, 0), {
                    text: "",
                    N: a4,
                    horiz: -1
                })
            }

            function aM(ba) {
                var a4 = new Point();
                var bc = null,
                    a9 = null;
                if ("A" in ba) {
                    bc = D(ba.A)
                } else {
                    if ("a" in ba) {
                        bc = 0;
                        if (Z) {
                            if (!Z.nodes[1]) {
                                a0(1)
                            }
                            var bb = Z.nodes[1].pt.subx(Z.nodes[0].pt);
                            bc = bb.polarAngle() * 180 / Math.PI
                        }
                        bc += D(ba.a)
                    }
                }
                if ("L" in ba) {
                    a9 = D(ba.L)
                }
                if (bc !== null || a9 !== null) {
                    if (bc === null) {
                        bc = 0
                    }
                    if (a9 === null) {
                        a9 = aH
                    }
                    a4.fromDeg(bc).muli(a9)
                }

                function i(bl, bi) {
                    if (!bl) {
                        return 0
                    }
                    if (bl.charAt(0) == "#") {
                        var bk = bl.substring(1).split(";"),
                            bh = 0,
                            bg, bj;
                        for (bg in bk) {
                            bj = X(bk[bg]);
                            bh += bj.pt[bi]
                        }
                        bh /= bk.length;
                        if (!aT) {
                            a0(1)
                        }
                        return bh - aT.pt[bi]
                    }
                    return D(bl)
                }
                if ("x" in ba || "y" in ba) {
                    a4.x = i(ba.x, "x");
                    a4.y = i(ba.y, "y")
                }
                if (("P" in ba) && Z) {
                    var a5 = +ba.P;
                    if (ba.P === true) {
                        a5 = 5
                    }
                    if (a5) {
                        var be = 0;
                        if ("#" in ba) {
                            var bf = S(ba["#"]);
                            if (bf) {
                                be = bf.pt
                            }
                        }
                        a4 = T(a5 < 0 ? -1 : 1, Math.abs(a5), be)
                    }
                }
                if ("p" in ba) {
                    var a8, a6, bd = ba.p.split(";"),
                        a7 = new Point();
                    for (a6 in bd) {
                        a8 = X(bd[a6]);
                        a7.addi(a8.pt)
                    }
                    a7.muli(1 / bd.length);
                    if (!aT) {
                        a0(1)
                    }
                    a4 = a7.subi(aT.pt)
                }
                aP.addi(a4);
                return a4
            }

            function Y(a4) {
                var a9, a6, a5 = aj(a4),
                    a8 = {
                        text: "_",
                        N: 1,
                        horiz: -1
                    };
                if (a5.H) {
                    a8.N = 0;
                    a8.style = ":"
                }
                if (a5.C) {
                    a8.N = 0;
                    a8.style = "|";
                    switch (a5.C || 0) {
                        case "-":
                            a8.arr0 = 1;
                            break;
                        case "+":
                            a8.arr0 = 1;
                            a8.arr1 = 1;
                            break;
                        default:
                            a8.arr1 = 1
                    }
                }
                if ("N" in a5) {
                    if (a5.N == "2x") {
                        a8.N = 2;
                        a8.cross = 1
                    } else {
                        a8.N = +a5.N
                    }
                }
                if ("h" in a5) {
                    a8.horiz = 1
                }
                if ("S" in a5) {
                    a8.style = a5.S
                }
                if ("T" in a5) {
                    a8.text = a5.T
                }
                if (">" in a5) {
                    a8.arr1 = 1
                }
                if ("<" in a5) {
                    a8.arr0 = 1
                }

                function i(bc, bb, ba) {
                    switch (a5[bc]) {
                        case "+":
                            a8.w0 = 0;
                            a8.w1 = bb;
                            break;
                        case "-":
                            a8.w0 = bb;
                            a8.w1 = 0;
                            break;
                        case "2":
                            a8.w0 = a8.w1 = bb;
                            break
                    }
                    if (ba) {
                        a3 = a8.w1
                    }
                }
                if ("w" in a5) {
                    i("w", 1)
                } else {
                    if ("W" in a5) {
                        i("W", 1, 1)
                    } else {
                        if ("d" in a5) {
                            i("d", -1)
                        } else {
                            if ("D" in a5) {
                                i("D", -1, 1)
                            } else {
                                a8.w0 = a8.w1 = a3
                            }
                        }
                    }
                }
                var a7 = aM(a5);
                am(a7, a8)
            }

            function j(a9) {
                var a5 = W[aw].L,
                    a8 = a5.length,
                    a4 = [];
                if (!a8) {
                    ao("Невозможно создать кольцо")
                }
                var ba = a5[--a8];
                if (!ba.nodes[1]) {
                    a0(1)
                }
                var a7 = ba.nodes[1],
                    a6, i = ba.nodes[0];
                a4.push(i);
                while (--a8 >= 0) {
                    ba = a5[a8];
                    a6 = ba.nodes[0];
                    if (ba.nodes[1] == i) {
                        a4.push(a6);
                        if (a6 == a7) {
                            break
                        }
                        i = a6
                    }
                }
                if (a6 != a7 || !a4.length) {
                    ao("Не удалось замкнуть кольцо")
                }
                ba = new ChemLink(a9);
                ba.type = "o";
                ba.nodes = a4;
                ai.links.push(ba)
            }
            var ar, aB;
            var al = {
                begin: function() {
                    if (/\s/.test(aZ)) {
                        return 1
                    }
                    if (aZ == '"') {
                        return aO("commPre", 1)
                    }
                    var i = at();
                    if (i !== null) {
                        return i
                    }
                    return aO("agent")
                },
                agent: function() {
                    av(new ChemAgent());
                    aJ();
                    return aO("agentPre")
                },
                agentPre: function() {
                    if (/\d/.test(aZ)) {
                        aO("agentK")
                    } else {
                        if (aZ == "'") {
                            return aO("agentKAbs", 1)
                        } else {
                            aO("agentIn")
                        }
                    }
                    return 0
                },
                itemCustom: function() {
                    if (aZ != "}") {
                        aV += aZ
                    } else {
                        aW(new ChemObjCustom(u(aV)));
                        aO("itemFinal")
                    }
                    return 1
                },
                charge: function() {
                    var a4 = aV + aZ,
                        i = d(a4);
                    if (i !== null) {
                        return ax()
                    }
                    if (aT.charge = d(aV)) {
                        aT.charge.left = af
                    }
                    af = 0;
                    return aO("chargePost")
                },
                chargePost: function() {
                    if (aZ == '"') {
                        return aO("comm", 1)
                    }
                    return aO("agentMid")
                },
                commPre: function() {
                    if (aZ != '"') {
                        aV += aZ
                    } else {
                        aK = aV;
                        aO("begin")
                    }
                    return 1
                },
                comm: function() {
                    if (aZ != '"') {
                        return ax()
                    }
                    if ("commentPost" in ai) {
                        ai.commentPost = h(aV);
                        return aO("begin", 1)
                    }
                    aW(new ChemObjComm(aV));
                    return aO("agentMid", 1)
                },
                agentK: function() {
                    if (/\d/.test(aZ)) {
                        aV += aZ;
                        return 1
                    }
                    ai.k = +aV;
                    return aO("agentPre")
                },
                agentKAbs: function() {
                    if (aZ != "'") {
                        aV += aZ;
                        return 1
                    }
                    ai.k = aV;
                    return aO("agentPre", 1)
                },
                agentSpace: function() {
                    if (/\s/.test(aZ)) {
                        return 1
                    }
                    return aO("agentIn")
                },
                agentIn: function() {
                    var i = aL();
                    if (i < 0) {
                        ao("Unknown element character '[C]'", {
                            C: aZ
                        })
                    }
                    return i
                },
                agentMid: function() {
                    var i = aL();
                    if (i < 0) {
                        ac();
                        return aO("begin")
                    }
                    return i
                },
                agentElem: function() {
                    if (aZ >= "a" && aZ <= "z") {
                        aV += aZ;
                        return 1
                    }
                    var i = MenTbl[aV];
                    if (!i) {
                        ao("Unknown element '[Elem]'", {
                            Elem: aV,
                            pos: aR + 1 - aV.length
                        })
                    }
                    aW(i);
                    return aO("itemFinal")
                },
                itemFinal: function() {
                    if (a1) {
                        aF().M = a1;
                        a1 = null
                    }
                    if (aZ >= "1" && aZ <= "9") {
                        return aO("elemCnt")
                    }
                    if (aZ == "'") {
                        return aO("elemCntAbs", 1)
                    }
                    if (aZ == "(") {
                        var a4 = ah.indexOf(")", aR + 1);
                        if (a4 >= 0) {
                            var a5 = ah.substring(aR + 1, a4),
                                i = d(a5);
                            if (i !== null) {
                                var a6 = aF();
                                if (a6) {
                                    a6.charge = i;
                                    aR = a4 + 1;
                                    return 0
                                }
                            }
                        }
                    }
                    return aO("agentMid")
                },
                elemCnt: function() {
                    if (aZ >= "0" && aZ <= "9") {
                        return ax()
                    }
                    aF().n = +aV;
                    return aO("itemFinal")
                },
                elemCntAbs: function() {
                    if (aZ != "'") {
                        return ax()
                    }
                    aF().n = aV;
                    return aO("itemFinal", 1)
                },
                negChar: function() {
                    af = 1;
                    if (x[aZ]) {
                        return aO("shortLink")
                    }
                    return aO("agentMid")
                },
                shortLink: function() {
                    var a4 = aV + aZ,
                        i = v(a4);
                    if (i) {
                        return ax()
                    }
                    aB = aV;
                    return aO("shortLinkSfx")
                },
                shortLinkSfx: function() {
                    if ("0vwdh~x".indexOf(aZ) >= 0) {
                        return ax()
                    }
                    U(aB, aV);
                    return aO("agentMid")
                },
                fullLink: function() {
                    if (aZ == "o") {
                        j("");
                        return aO("agentMid", 1)
                    }
                    if (aZ == "m") {
                        return aO("midPt", 1)
                    }
                    if (aZ == "p" || aZ == "q") {
                        var i = aZ == "p" ? 1 : -1,
                            a5 = 1,
                            a4 = "";
                        if (ah.charAt(++aR) == aZ) {
                            a5 = 2;
                            aR++
                        }
                        while (/\d/.test(ah.charAt(aR))) {
                            a4 += ah.charAt(aR++)
                        }
                        a4 = (+a4) || 5;
                        au(i, a4, a5);
                        return aO("agentMid", 0)
                    }
                    if (aZ == "(") {
                        return aO("fullLink1", 1)
                    }
                    Y("");
                    return aO("agentMid")
                },
                fullLink1: function() {
                    if (aZ != ")") {
                        aV += aZ;
                        return 1
                    }
                    Y(aV);
                    return aO("agentMid", 1)
                },
                midPt: function() {
                    if (aZ != "(") {
                        ao("Expected '(' after [S]", {
                            S: "_m"
                        })
                    } else {
                        return aO("midPtDef", 1)
                    }
                },
                midPtDef: function() {
                    if (aZ != ")") {
                        return ax(aZ)
                    }
                    var i = aj(aV),
                        a4 = aM(i);
                    P = P || [];
                    P.push(a4);
                    return aO("agentMid", 1)
                },
                label: function() {
                    if (/[\dA-Z]/i.test(aZ)) {
                        return ax()
                    }
                    if (!aT) {
                        a0(1)
                    }
                    ab[aV] = aT;
                    return aO("agentMid")
                },
                nodeRef: function() {
                    ar = "";
                    if (aZ >= "0" && aZ <= "9") {
                        return aO("nodeRefDig")
                    }
                    if (aZ == "-") {
                        ar = aZ;
                        return aO("nodeRefDig", 1)
                    }
                    if (/[A-Z]/i.test(aZ)) {
                        return aO("nodeRefChr")
                    }
                    if (/\s/.test(aZ)) {
                        return aO("agentSpace", 1)
                    }
                    ar = aZ;
                    return aO("nodeRefEnd")
                },
                nodeRefDig: function() {
                    if (aZ >= "0" && aZ <= "9") {
                        ar += aZ;
                        return 1
                    }
                    return aO("nodeRefEnd")
                },
                nodeRefChr: function() {
                    if (/[A-Z\d]/i.test(aZ)) {
                        ar += aZ;
                        return 1
                    }
                    return aO("nodeRefEnd")
                },
                nodeRefEnd: function() {
                    var i = X(ar);
                    i.bFix = 1;
                    aC(i);
                    return aO("agentMid")
                },
                funcName: function() {
                    if (aZ != "(") {
                        return ax()
                    }
                    aI = aV;
                    return aO("funcArg", 1)
                },
                funcArg: function() {
                    if (aZ != ")") {
                        return ax()
                    }
                    var i = funcs[aI];
                    if (i) {
                        i(aV)
                    }
                    return aO("agentMid", 1)
                }
            };
            try {
                var aQ = preProcess(ah);
                if (!aQ.ok) {
                    ao(aQ.msg)
                }
                ah = ae.post = aQ.dst;
                while (aR < ah.length) {
                    aZ = ah.charAt(aR);
                    aN = al[aA]();
                    if (aN > 0) {
                        aR++
                    }
                    if (aN < 0) {
                        break
                    }
                }
            } catch (aY) {
                if (aY instanceof r) {
                    ae.error = aY
                } else {
                    ae.error = new r("Internal error: [msg]", {
                        msg: aY.message
                    })
                }
            }
            return ae
        };

        function K(O) {
            var L, S, N, P = O[0],
                i = this.tables[0],
                R = [],
                Q = [];
            for (N = 0; N < i.NCol; N++) {
                R.push(L = i.x1 + N);
                S = i.y1;
                while (S < P.length && !P[S][L]) {
                    S++
                }
                Q.push(S);
                if (S < P.length) {
                    P[S - 1][L] = {
                        text: this.groupIds[N],
                        cls: this.groupCls
                    }
                }
            }
            S = Q[7];
            if (this.groupIds[8].indexOf("8B") >= 0 && S < P.length && S == Q[8] && Q[8] == Q[9]) {
                L = R[7];
                S--;
                P[S][L].text += P[S][L + 1].text + P[S][L + 2].text;
                P[S][L].colspan = 3;
                P[S][++L] = null;
                P[S][++L] = null
            }
        }
        this.TblRules = {
            Std: {
                flGroups: 0,
                flPeriods: 0,
                flLanAct: 0,
                tables: [{
                    NCol: 18,
                    NRow: 7
                }, {
                    NCol: 15,
                    NRow: 2
                }],
                category: MenTblCategoryBlock,
                points: {
                    He: [17, 0],
                    B: [12, 1],
                    Al: [12, 2],
                    La: [0, 0, 1],
                    Hf: [3, 5],
                    Ac: [0, 1, 1],
                    Rf: [3, 6]
                },
                notes: {
                    La: [2, 5],
                    Ac: [2, 6]
                },
                groupIds: ["1A", "2A", "3B", "4B", "5B", "6B", "7B", "┌──", "─8B─", "──┐", "1B", "2B", "3A", "4A", "5A", "6A", "7A", "8A"],
                groupCls: "group-id",
                drawGroups: K
            },
            Wide: {
                tables: [{
                    NCol: 32,
                    NRow: 7
                }],
                category: MenTblCategoryProps,
                points: {
                    H: [0, 0],
                    He: [31, 0],
                    B: [26, 1],
                    Al: [26, 2],
                    Sc: [16, 3],
                    Y: [16, 4]
                },
                groupIds: "1A,2A,,,,,,,,,,,,,,,3B,4B,5B,6B,7B,┌──,8B,──┐,1B,2B,3A,4A,5A,6A,7A,8A".split(","),
                groupCls: "group-id",
                pre: function(i) {},
                drawGroups: K
            },
            Short: {
                tables: [{
                    NCol: 11,
                    NRow: 11,
                    periodCols: 2,
                    groupRows: 2
                }, {
                    NCol: 15,
                    NRow: 2
                }],
                points: {
                    H: [0, 0],
                    He: [10, 0],
                    Ne: [10, 1],
                    Ar: [10, 2],
                    Cu: [0, 4],
                    Kr: [10, 4],
                    Ag: [0, 6],
                    Xe: [10, 6],
                    La: [0, 0, 1],
                    Hf: [3, 7],
                    Au: [0, 8],
                    Rn: [10, 8],
                    Ac: [0, 1, 1],
                    Rf: [3, 9],
                    Rg: [0, 10]
                },
                flLanAct: 1,
                notes: {
                    La: [2, 7],
                    Ac: [2, 9]
                },
                category: MenTblCategoryBlock,
                categoryExt: [MenTblSubGroup],
                groupIds: "I:a;b,II:a;b,III:a;b,IV:a;b,V:a;b,VI:a;b,VII:a;b,::R,VIII:b:LR,::LR,:a:L".split(","),
                groupCls: "chem-cell",
                drawGroups: function(P) {
                    var O, R, N, L, j = this.tables[0],
                        Q = P[0];
                    for (O = 0; O < j.NCol; O++) {
                        N = this.groupIds[O].split(":");
                        R = {
                            cls: this.groupCls,
                            rowspan: 2,
                            text: N[0] + '<div class="mentable-subgroup-hd">'
                        };
                        if (N.length > 1) {
                            L = N[1].split(";");
                            if (L.length == 2) {
                                R.text += '<span class="left">' + L[0] + '</span><span class="right">' + L[1] + "</span>"
                            } else {
                                R.text += L[0]
                            }
                        }
                        if (N.length > 2) {
                            if (N[2].indexOf("L") >= 0) {
                                R.cls += " noleft"
                            }
                            if (N[2].indexOf("R") >= 0) {
                                R.cls += " noright"
                            }
                        }
                        R.text += "</div>";
                        Q[j.y1 - 2][O + j.x1] = R;
                        Q[j.y1 - 1][O + j.x1] = null
                    }
                },
                drawPeriods: function(N) {
                    var L, P, Q = 1,
                        j = this.tables[0],
                        O = N[0];
                    for (L = 0; L < j.NRow; L++) {
                        P = (L < 3 || L & 1) ? {
                            text: Q++,
                            cls: "period-id"
                        } : null;
                        if (P && L >= 3) {
                            P.rowspan = 2
                        }
                        O[j.y1 + L][j.x1 - 2] = P
                    }
                    for (L = 0; L < j.NRow; L++) {
                        O[j.y1 + L][j.x1 - 1] = {
                            text: L + 1,
                            cls: "period-id"
                        }
                    }
                },
                post: function(i) {
                    if (this.flGroups && this.flPeriods) {
                        i[0][0][0] = {
                            text: M("Group") + "→",
                            cls: "mentable-text period-id",
                            colspan: 2
                        };
                        i[0][0][1] = null;
                        i[0][1][0] = {
                            text: M("Period"),
                            cls: "mentable-text period-id"
                        };
                        i[0][1][1] = {
                            text: M("Row"),
                            cls: "mentable-text period-id"
                        }
                    }
                },
                pre: function(R) {
                    var N, P, O = 0,
                        S, Q = R[0],
                        L = this.tables[0];
                    for (; O < L.NRow; O++) {
                        S = Q[O + L.y1];
                        for (P = 0; P < L.NCol; P++) {
                            S[P + L.x1] = (P > 6 && P < 10) ? {
                                cls: "chem-row"
                            } : {
                                cls: "chem-cell"
                            }
                        }
                    }
                }
            }
        };
        this.CellRender = function(i) {
            if (!i) {
                i = "number,id,name,mass"
            }
            if (typeof i == "string") {
                i = i.split(",")
            }
            this.fields = i;
            this.div = function(L, P, N) {
                var j, O = '<div class="' + L + '"';
                if (N) {
                    for (j in N) {
                        O += " " + j + '="' + N[j] + '"'
                    }
                }
                return O + ">" + (P + "").replace(/</g, "&lt;").replace(/>/g, "&gt;") + "</div>"
            };
            this.number = function(j) {
                return this.div("number", j.n)
            };
            this.id = function(j) {
                return this.div("id", j.id)
            };
            this.name = function(j) {
                return this.div("name", M(j.id))
            };
            this.mass = function(j) {
                return this.div("mass", j.M)
            };
            this.draw = function(N) {
                var j, O, L = "";
                for (j in this.fields) {
                    O = this.fields[j];
                    if (O in this) {
                        L += this[O](N)
                    }
                }
                return L
            }
        };
        this.drawTable = function(R) {
            if (!R) {
                R = this.TblRules.Std
            }
            var V = 0,
                aa, X = 0,
                N, ad, O, P, T, ab, ac = [];
            for (; V < R.tables.length; V++) {
                ab = R.tables[V];
                ac[V] = [];
                ab.width = ab.width || ab.NCol;
                ab.height = ab.height || ab.NRow;
                ab.ofsX = ab.ofsX || 0;
                ab.ofsY = ab.ofsY || 0;
                ab.w1 = ab.width;
                ab.h1 = ab.height;
                ab.x1 = ab.ofsX;
                ab.y1 = ab.ofsY;
                if (V == 0) {
                    if (R.flGroups) {
                        T = ab.groupRows || 1;
                        ab.y1 += T;
                        ab.h1 += T
                    }
                    if (R.flPeriods) {
                        T = ab.periodCols || 1;
                        ab.x1 += T;
                        ab.w1 += T
                    }
                }
                for (X = 0; X < ab.h1; X++) {
                    ac[V][X] = new Array(ab.w1)
                }
            }
            if (R.pre) {
                R.pre(ac)
            }
            var W, Z = [],
                S, L = [];
            if (R.category) {
                L.push(R.category)
            }
            if (R.categoryExt) {
                for (aa in R.categoryExt) {
                    L.push(R.categoryExt[aa])
                }
            }
            for (V in L) {
                S = L[V];
                Z.push(W = {});
                for (aa in S) {
                    ad = S[aa];
                    if (typeof ad == "string") {
                        ad = ad.split(",")
                    }
                    for (X in ad) {
                        W[ad[X]] = aa
                    }
                }
            }
            L = new Array(Z.length);
            ab = R.tables[T = 0];
            X = ab.y1;
            aa = ab.x1;
            for (V in MenTbl) {
                ad = MenTbl[V];
                N = R.points[ad.id];
                if (N) {
                    ab = R.tables[T = N[2] || 0];
                    aa = N[0] + ab.x1;
                    X = N[1] + ab.y1
                }
                P = "chem-element";
                for (W in Z) {
                    S = Z[W];
                    if (S[ad.id]) {
                        L[W] = S[ad.id]
                    }
                }
                P += " " + L.join(" ");
                ac[T][X][aa] = {
                    elem: ad,
                    cls: P
                };
                if (++aa == ab.x1 + ab.NCol) {
                    aa = ab.x1;
                    X++
                }
            }
            if (R.flGroups) {
                if (R.drawGroups) {
                    R.drawGroups(ac)
                } else {
                    for (aa = 0; aa < ab.NCol; aa++) {
                        ac[0][ab.y1 - 1][ab.x1 + aa] = {
                            text: aa + 1
                        }
                    }
                }
            }
            ab = R.tables[0];
            if (R.flPeriods) {
                if (R.drawPeriods) {
                    R.drawPeriods(ac)
                } else {
                    for (aa = 0; aa < ab.NRow; aa++) {
                        ac[0][ab.y1 + aa][ab.x1 - 1] = {
                            text: aa + 1,
                            cls: "period-id"
                        }
                    }
                }
            }
            if (R.post) {
                R.post(ac)
            }
            var Y = {
                La: "57-71<br>" + M("Lanthanides"),
                Ac: "89-103<br>" + M("Actinides")
            };
            if (R.flLanAct && R.notes) {
                ab = R.tables[0];
                for (aa in R.notes) {
                    N = R.notes[aa];
                    ac[0][N[1] + ab.y1][N[0] + ab.x1] = {
                        text: Y[aa],
                        cls: "chem-cell mentable-text"
                    }
                }
            }
            var U = "",
                Q = R.cellRender || new ChemSys.CellRender();
            for (V in ac) {
                U += R.beginTable ? R.beginTable(V) : '<table class="mentable">';
                T = ac[V];
                for (X = 0; X < T.length; X++) {
                    O = T[X];
                    U += "<tr>";
                    for (aa = 0; aa < O.length; aa++) {
                        ad = O[aa];
                        if (!ad) {
                            if (ad !== null) {
                                U += "<td></td>"
                            }
                        } else {
                            U += '<td class="' + (ad.cls ? ad.cls : "chem-element") + '"';
                            if (ad.colspan) {
                                U += ' colspan="' + ad.colspan + '"'
                            }
                            if (ad.rowspan) {
                                U += ' rowspan="' + ad.rowspan + '"'
                            }
                            U += ">";
                            if (ad.elem) {
                                U += Q.draw(ad.elem)
                            } else {
                                if (ad.text) {
                                    U += ad.text
                                }
                            }
                            U += "</td>"
                        }
                    }
                    U += "</tr>"
                }
                U += "</table>"
            }
            return U
        };
        this.navLang = navigator.language || navigator.browserLanguage || navigator.userLanguage;
        this.curLang = this.navLang = this.navLang.split("-")[0];
        this.Dict = {
            ru: {
                $Native: "Русский",
                $English: "Russian",
                "Internal error: [msg]": "Внутренняя ошибка: [msg]",
                "Unexpected '[C]' in position [pos]": "Неверный символ '[C]' в позиции [pos]",
                "Expected '[ok]' instead of '[bad]' in position [pos]": "Требуется '[ok]' вместо '[bad]' в позиции [pos]",
                "Invalid character '[C]' in position [pos]": "Недопустимый символ '[C]' в позиции [pos]",
                "Unknown element character '[C]' in position [pos]": "Недопустимый символ '[C]' описания реагента в позиции [pos]",
                "Expected '[C]' in position [pos]": "Требуется '[C]' в позиции [pos]",
                "Unknown element '[Elem]' in position [pos]": "Ошибочный элемент '[Elem]' в позиции [pos]",
                "Browser does not support canvas-graphics": "Браузер не поддерживает canvas-графику",
                "Formula can not be displayed as text": "Формулу нельзя отобразить в текстовом виде",
                "Expected '(' after [S]": " Требуется '(' после [S]",
                "Invalid version": "Формула требует версии системы [need] вместо [cur]",
                "(s)": "(тв)",
                "(l)": "(ж)",
                "(g)": "(г)",
                "(aq)": "(р-р)",
                "Periodic Table": "Периодическая система химических элементов",
                "Table legend": "Группы химических элементов",
                Group: "Группа",
                Period: "Период",
                Row: "Ряд",
                "[x]-block": "[x]-блок",
                Lanthanides: "Лантаноиды",
                Actinides: "Актиноиды",
                "Alkali metals": "Щелочные металлы",
                "Alkaline earth metals": "Щёлочноземельные металлы",
                "Transition metals": "Переходные металлы",
                "Post transition metals": "Постпереходные металлы",
                Metalloids: "Полуметаллы",
                "Other nonmetals": "Неметаллы",
                Halogens: "Галогены",
                "Noble gases": "Инертные газы",
                "Unknown props": "Св-ва неизвестны",
                H: "Водород",
                He: "Гелий",
                Li: "Литий",
                Be: "Бериллий",
                B: "Бор",
                C: "Углерод",
                N: "Азот",
                O: "Кислород",
                F: "Фтор",
                Ne: "Неон",
                Na: "Натрий",
                Mg: "Магний",
                Al: "Алюминий",
                Si: "Кремний",
                P: "Фосфор",
                S: "Сера",
                Cl: "Хлор",
                Ar: "Аргон",
                K: "Калий",
                Ca: "Кальций",
                Sc: "Скандий",
                Ti: "Титан",
                V: "Ванадий",
                Cr: "Хром",
                Mn: "Марганец",
                Fe: "Железо",
                Co: "Кобальт",
                Ni: "Никель",
                Cu: "Медь",
                Zn: "Цинк",
                Ga: "Галлий",
                Ge: "Германий",
                As: "Мышьяк",
                Se: "Селен",
                Br: "Бром",
                Kr: "Криптон",
                Rb: "Рубидий",
                Sr: "Стронций",
                Y: "Иттрий",
                Zr: "Цирконий",
                Nb: "Ниобий",
                Mo: "Молибден",
                Tc: "Технеций",
                Ru: "Рутений",
                Rh: "Родий",
                Pd: "Палладий",
                Ag: "Серебро",
                Cd: "Кадмий",
                In: "Индий",
                Sn: "Олово",
                Sb: "Сурьма",
                Te: "Теллур",
                I: "Йод",
                Xe: "Ксенон",
                Cs: "Цезий",
                Ba: "Барий",
                La: "Лантан",
                Ce: "Церий",
                Pr: "Празеодим",
                Nd: "Неодим",
                Pm: "Прометий",
                Sm: "Самарий",
                Eu: "Европий",
                Gd: "Гадолиний",
                Tb: "Тербий",
                Dy: "Диспрозий",
                Ho: "Гольмий",
                Er: "Эрбий",
                Tm: "Тулий",
                Yb: "Иттербий",
                Lu: "Лютеций",
                Hf: "Гафний",
                Ta: "Тантал",
                W: "Вольфрам",
                Re: "Рений",
                Os: "Осмий",
                Ir: "Иридий",
                Pt: "Платина",
                Au: "Золото",
                Hg: "Ртуть",
                Tl: "Таллий",
                Pb: "Свинец",
                Bi: "Висмут",
                Po: "Полоний",
                At: "Астат",
                Rn: "Радон",
                Fr: "Франций",
                Ra: "Радий",
                Ac: "Актиний",
                Th: "Торий",
                Pa: "Протактиний",
                U: "Уран",
                Np: "Нептуний",
                Pu: "Плутоний",
                Am: "Америций",
                Cm: "Кюрий",
                Bk: "Берклий",
                Cf: "Калифорний",
                Es: "Эйнштейний",
                Fm: "Фермий",
                Md: "Менделеевий",
                No: "Нобелий",
                Lr: "Лоуренсий",
                Rf: "Резерфордий",
                Db: "Дубний",
                Sg: "Сиборгий",
                Bh: "Борий",
                Hs: "Хассий",
                Mt: "Мейтнерий",
                Ds: "Дармштадтий",
                Rg: "Рентгений",
                Cn: "Коперниций"
            },
            en: {
                "Invalid version": "Required system version [need] instead of [cur]",
                $Native: "English",
                $English: "English",
                "Table legend": "Chemical element groups",
                H: "Hydrogen",
                He: "Helium",
                Li: "Lithium",
                Be: "Beryllium",
                B: "Boron",
                C: "Carbon",
                N: "Nitrogen",
                O: "Oxygen",
                F: "Fluorine",
                Ne: "Neon",
                Na: "Sodium",
                Mg: "Magnesium",
                Al: "Aluminium",
                Si: "Silicon",
                P: "Phosphorus",
                S: "Sulfur",
                Cl: "Chlorine",
                Ar: "Argon",
                K: "Potassium",
                Ca: "Calcium",
                Sc: "Scandium",
                Ti: "Titanium",
                V: "Vanadium",
                Cr: "Chromium",
                Mn: "Manganese",
                Fe: "Iron",
                Co: "Cobalt",
                Ni: "Nickel",
                Cu: "Copper",
                Zn: "Zinc",
                Ga: "Gallium",
                Ge: "Germanium",
                As: "Arsenic",
                Se: "Selenium",
                Br: "Bromine",
                Kr: "Krypton",
                Rb: "Rubidium",
                Sr: "Strontium",
                Y: "Yttrium",
                Zr: "Zirconium",
                Nb: "Niobium",
                Mo: "Molybdenum",
                Tc: "Technetium",
                Ru: "Ruthenium",
                Rh: "Rhodium",
                Pd: "Palladium",
                Ag: "Silver",
                Cd: "Cadmium",
                In: "Indium",
                Sn: "Tin",
                Sb: "Antimony",
                Te: "Tellurium",
                I: "Iodine",
                Xe: "Xenon",
                Cs: "Caesium",
                Ba: "Barium",
                La: "Lanthanum",
                Ce: "Cerium",
                Pr: "Praseodymium",
                Nd: "Neodymium",
                Pm: "Promethium",
                Sm: "Samarium",
                Eu: "Europium",
                Gd: "Gadolinium",
                Tb: "Terbium",
                Dy: "Dysprosium",
                Ho: "Holmium",
                Er: "Erbium",
                Tm: "Thulium",
                Yb: "Ytterbium",
                Lu: "Lutetium",
                Hf: "Hafnium",
                Ta: "Tantalum",
                W: "Tungsten",
                Re: "Rhenium",
                Os: "Osmium",
                Ir: "Iridium",
                Pt: "Platinum",
                Au: "Gold",
                Hg: "Mercury",
                Tl: "Thallium",
                Pb: "Lead",
                Bi: "Bismuth",
                Po: "Polonium",
                At: "Astatine",
                Rn: "Radon",
                Fr: "Francium",
                Ra: "Radium",
                Ac: "Actinium",
                Th: "Thorium",
                Pa: "Protactinium",
                U: "Uranium",
                Np: "Neptunium",
                Pu: "Plutonium",
                Am: "Americium",
                Cm: "Curium",
                Bk: "Berkelium",
                Cf: "Californium",
                Es: "Einsteinium",
                Fm: "Fermium",
                Md: "Mendelevium",
                No: "Nobelium",
                Lr: "Lawrencium",
                Rf: "Rutherfordium",
                Db: "Dubnium",
                Sg: "Seaborgium",
                Bh: "Bohrium",
                Hs: "Hassium",
                Mt: "Meitnerium",
                Ds: "Darmstadtium",
                Rg: "Roentgenium",
                Cn: "Copernicium"
            }
        };
        this.addDict = function(O) {
            var N, j, L, i;
            for (N in O) {
                j = O[N];
                L = this.Dict[N];
                if (!L) {
                    this.Dict[N] = j
                } else {
                    for (i in j) {
                        L[i] = j[i]
                    }
                }
            }
        };

        function M(L, Q, P) {
            var j, O = ChemSys.Dict[P || ChemSys.curLang] || ChemSys.Dict.en,
                N = O[L];
            if (N === undefined) {
                N = L
            }
            if (Q) {
                for (j in Q) {
                    N = N.replace(new RegExp("\\[" + j + "\\]", "g"), Q[j])
                }
            }
            return N
        }
        this.lang = M;

        function z(i) {
            this.type = i;
            this.pos = new Point();
            this.sz = new Point()
        }

        function g(i) {
            z.call(this, "lines");
            this.pts = [];
            this.bFill = !!i;
            this.w = 1
        }
        g.prototype = {
            add: function(j, i) {
                var L = j.clone();
                if (i) {
                    L.mv = i
                }
                this.pts.push(L)
            }
        };

        function I() {
            this.pts = [];
            z.call(this, "curve")
        }
        I.prototype = {
            add: function(N) {
                function j(O, i) {
                    O.pts.push(i.clone())
                }
                if (N instanceof Array) {
                    for (var L in N) {
                        j(this, N[L])
                    }
                } else {
                    j(this, N)
                }
            }
        };

        function F() {
            z.call(this, "frame");
            this.org = new Point();
            this.frms = [];
            this.prims = []
        }
        F.prototype = {
            add: function(i) {
                this[i.type == "frame" ? "frms" : "prims"].push(i)
            },
            update: function() {
                var L = 0,
                    j, P, Q, N;

                function O(i) {
                    for (P in i) {
                        Q = i[P];
                        N = Q.pos.addx(Q.sz);
                        if (!L) {
                            L = Q.pos.clone();
                            j = N
                        } else {
                            L.mini(Q.pos);
                            j.maxi(N)
                        }
                    }
                }
                O(this.frms);
                O(this.prims);
                if (L) {
                    this.org = L;
                    this.sz = j.subi(L)
                }
            }
        };
        this.buildFrame = function(L, al) {
            var af = new F(),
                T, ap, au, R, an, S, Q = [0, 0, 0],
                aa = al.lineLen,
                ab = aa.line,
                V = aa.horiz,
                N = aa.thick,
                O = aa.width,
                ah = aa.dash,
                aj = aa.width * 2,
                i = aa.width * 1.5,
                ak, ad, aw = 0,
                ae = 0,
                P = {
                    text: "A",
                    fntId: "std",
                    sz: new Point()
                };
            al.setTextProps(P);
            Q[1] = P.sz.y / 2;
            P.fntId = "half";
            al.setTextProps(P);
            Q[2] = Q[1] - P.sz.y;

            function at(X, j) {
                if (au.bCenter) {
                    j = 5
                }
                if (!ak || j > ad) {
                    ak = X;
                    ad = j
                }
            }

            function av(ax, X, Y) {
                var j = new z("text");
                ax += "";
                j.fntId = X;
                j.text = ax;
                al.setTextProps(j);
                if (Y.color) {
                    j.color = Y.color
                }
                an = Math.max(an, j.sz.y);
                return j
            }

            function ag(j, Y, ax) {
                if (aw) {
                    return
                }
                var X = av(j, Y, au);
                ap.add(X);
                if (!ax) {
                    S[0] = Math.max(S[1], S[2])
                }
                X.pos.init(S[ax], Q[ax]);
                S[ax] += X.sz.x;
                if (!ax) {
                    S[2] = S[1] = S[0]
                }
                return X
            }

            function U(j) {
                var Y = ap.prims[ap.prims.length - 1];
                if (!Y) {
                    return
                }
                var X = av(j, "half", au);
                ap.add(X);
                X.pos = new Point(Y.pos.x + (Y.sz.x - X.sz.x) / 2, Y.pos.y - X.sz.y * 0.8)
            }
            var ac, Z = 0;

            function am(X) {
                var j = ac.charge;
                if (j && j.left == X) {
                    ag(j.text, "half", 2)
                }
            }
            var aq = 1;
            L.walk({
                entityPre: function(j) {
                    af.add(T = new F())
                },
                agentPre: function(j) {
                    if (!T) {
                        af.add(T = new F());
                        Z = 1
                    }
                },
                nodePre: function(j) {
                    aw = j.bAuto;
                    T.add(ap = new F());
                    S = [0, 0, 0];
                    ak = null;
                    ad = 0;
                    aq = 1;
                    ac = j
                },
                itemPre: function(j) {
                    S[0] = S[1] = S[2] = Math.max(S[1], S[2]);
                    au = j;
                    if (j.M) {
                        ag(j.M, "half", 2)
                    }
                    if (aq) {
                        am(aq--)
                    }
                    R = new Point(S[0], Q[0]);
                    an = 0
                },
                atom: function(Y) {
                    if (aw) {
                        return
                    }
                    var j = ag(Y.id, "Atom", 0);
                    var X = 2;
                    if (Y.id == "H") {
                        X = 1
                    } else {
                        if (Y.id == "C") {
                            X = 3
                        }
                    }
                    at(j, X);
                    if (au.atomColor) {
                        j.color = au.atomColor
                    }
                },
                custom: function(j) {
                    ag(j.text, "Custom", 0)
                },
                comm: function(j) {
                    ag(j.text, "Comment", 0)
                },
                groupPre: function(j) {
                    ag(j.beg, "std", 0)
                },
                groupPost: function(j) {
                    ag(j.end, "std", 0)
                },
                itemPost: function(ay) {
                    var aB, aC, aG = new Point(S[0], Q[0] + an);
                    if (ay.charge) {
                        U(ay.charge.text)
                    }
                    if (ay.n != 1) {
                        ag(ay.n, "half", 1)
                    }
                    if (!ac.bAuto && (aB = ay.dots)) {
                        var az, ax, aJ, aF;

                        function Y(aN, aL) {
                            var aM = aj * 2;
                            if (az & 2) {
                                aM = -aM
                            }
                            if (aL) {
                                aM = -aM
                            }
                            return aN + aM
                        }
                        for (az = 0; az < 8; az++) {
                            ax = 1 << az;
                            if (!(aB & ax)) {
                                continue
                            }
                            ap.add(aC = new z("circle"));
                            if (az < 2 || az == 4 || az == 5) {
                                aJ = Y((R.x + aG.x) / 2, az & 1)
                            } else {
                                aJ = az & 1 ? Y(aG.x - aj, 1) : Y(R.x + aj)
                            }
                            aF = az & 4 ? Y(aG.y - aj) : Y(R.y + aj, 1);
                            aC.c = new Point(aJ, aF);
                            aC.r = i;
                            aC.color = ay.color;
                            aC.bFill = 1
                        }
                    }
                    if (!ac.bAuto && (aB = ay.dashes)) {
                        ap.add(aC = new g());
                        aC.color = ay.color;
                        var aJ, aF, X = R.x - aj,
                            j = aG.x + aj,
                            aI = R.y - aj,
                            aE = aG.y + aj,
                            aA = Math.min(aG.x - R.x - aj, aG.y - R.y - aj);

                        function aK(aM, aL, aO, aN) {
                            aC.add(new Point(aM, aL), 1);
                            aC.add(new Point(aO, aN))
                        }
                        if (aB & 1) {
                            aK(aJ = (X + j - aA) / 2, aI, aJ + aA, aI)
                        }
                        if (aB & 8) {
                            aK(j, aF = (aI + aE - aA) / 2, j, aF + aA)
                        }
                        if (aB & 2) {
                            aK(aJ = (X + j - aA) / 2, aE, aJ + aA, aE)
                        }
                        if (aB & 4) {
                            aK(X, aF = (aI + aE - aA) / 2, X, aF + aA)
                        }
                        var aD = aA * 0.53,
                            aH = aA * 0.17677;
                        if (aB & 16) {
                            aK(X + aD, aI - aH, X - aH, aI + aD)
                        }
                        if (aB & 32) {
                            aK(j - aD, aI - aH, j + aH, aI + aD)
                        }
                        if (aB & 64) {
                            aK(X + aD, aE + aH, X - aH, aE - aD)
                        }
                        if (aB & 128) {
                            aK(j - aD, aE + aH, j + aH, aE - aD)
                        }
                    }
                },
                nodePost: function(j) {
                    am(0);
                    aw = 0;
                    ap.update();
                    if (ak) {
                        ap.c = ak.sz.mulx(0.5).addi(ak.pos)
                    } else {
                        ap.c = ap.sz.mulx(0.5).addi(ap.org)
                    }
                },
                agentPost: function(X) {
                    if (X.nodes.length == 0) {
                        return
                    }
                    var aZ, bc, bk, bj, a6, bg = N / 2,
                        aR, aG = {};
                    var bd, bb, ay, aO, a8, ba = X.nodes[0].sc;
                    for (bd in X.nodes) {
                        X.nodes[bd].ufl = 0
                    }
                    for (bd in X.links) {
                        ay = X.links[bd];
                        for (bb = 0; bb < ay.nodes.length; bb++) {
                            aO = ay.nodes[bb];
                            if (aO.ufl++) {
                                continue
                            }
                            a8 = T.frms[aO.i];
                            var aC = aO.pt.mulx(ab);
                            if (aO.sc != ba) {
                                aR = aG[aO.sc];
                                if (!aR) {
                                    var aE = ay.nodes[bb ^ 1];
                                    if (!aE) {
                                        return
                                    }
                                    var aI = T.frms[aE.i];
                                    if (!aI) {
                                        return
                                    }
                                    var ax = (aO.pt.x - aE.pt.x) * V;
                                    bk = aI.pos.clone();
                                    bk.y += aI.c.y;
                                    if (ax < 0) {
                                        bk.x += ax - a8.sz.x + a8.c.x
                                    } else {
                                        bk.x += aI.sz.x + ax + a8.c.x
                                    }
                                    aR = bk.subx(aC);
                                    aG[aO.sc] = aR
                                }
                                aC.addi(aR)
                            }
                            a8.pos = aC.subi(a8.c)
                        }
                    }

                    function bh(a2, bn) {
                        var a1 = a2.nodes[bn];
                        var j = T.frms[a1.i];
                        var bm = j.pos.addx(j.c);
                        if (a2.bHoriz) {
                            bm.x = j.pos.x;
                            if (a1.pt.x - a2.nodes[bn ^ 1].pt.x < 0) {
                                bm.x += j.sz.x
                            }
                        }
                        return bm
                    }
                    var aY;

                    function aH(a1, j, bm) {
                        var a2 = new Point();
                        if (Math.abs(a1.x - j.x) < Math.abs(a1.y - j.y)) {
                            a2.x = bm
                        } else {
                            a2.y = bm
                        }
                        return a2
                    }

                    function aQ(bp, bx, bv) {
                        if (bp.bAuto) {
                            return bx
                        }
                        if (ChemSys.isEmptyNode(bp)) {
                            return bx
                        }

                        function a1(bz, bA) {
                            return bz ? 1 << bA : 0
                        }

                        function j(bz) {
                            return a1(bz.x < bm.x, 0) | a1(bz.x > a2.x, 1) | a1(bz.y < bm.y, 2) | a1(bz.y > a2.y, 3)
                        }
                        var br = T.frms[bp.i],
                            bt, bq, bm, a2, bw, bo, bn, by = bv.subx(bx),
                            bs = by.y == 0 ? 1000000 : Math.abs(by.x / by.y),
                            bu;
                        for (bt in br.prims) {
                            bq = br.prims[bt];
                            bm = bq.pos.addx(br.pos);
                            a2 = bm.addx(bq.sz);
                            a2.y -= bq.sz.y * 0.2;
                            bu = Math.abs(bq.sz.x / (a2.y - bm.y));
                            bo = j(bx);
                            bn = j(bv);
                            if (bn == 0) {
                                return bv
                            }
                            if (bo != 0) {
                                continue
                            }
                            if (bn & 2 && bu < bs) {
                                bx.y += (a2.x - bx.x) * by.y / by.x;
                                bx.x = a2.x;
                                return bx
                            }
                            if (bn & 1 && bu < bs) {
                                bx.y += (bm.x - bx.x) * by.y / by.x;
                                bx.x = bm.x;
                                return bx
                            }
                            if (bn & 4) {
                                bx.x += (bm.y - bx.y) * by.x / by.y;
                                bx.y = bm.y;
                                return bx
                            }
                            if (bn & 8) {
                                bx.x += (a2.y - bx.y) * by.x / by.y;
                                bx.y = a2.y;
                                return bx
                            }
                        }
                        return bx
                    }

                    function aL(bm, a2) {
                        var a1 = bh(ay, bm),
                            j = bh(ay, a2);
                        if (!ay.bHoriz) {
                            a1 = aQ(ay.nodes[bm], a1, j);
                            j = aQ(ay.nodes[a2], j, a1)
                        }
                        return [a1, j]
                    }

                    function aP(bp, bo, bm) {
                        var br = aL(bp, bo),
                            bt = br[0];
                        bj = br[1], a6 = aH(bt, bj, bg), aK = bj.subx(a6), aJ = bj.addx(a6);
                        T.add(aZ = new g(!bm));
                        if (bm) {
                            aK.subi(bt);
                            aJ.subi(bt);
                            var bs = bj.dist(bt),
                                a2 = aK.length(),
                                a1 = aJ.length();
                            var bq, j = 3,
                                bn = 1 / bs;
                            for (bq = 0; bq < bs; bq += j) {
                                aZ.add(aK.mulx(bq * bn).addi(bt), 1);
                                aZ.add(aJ.mulx(bq * bn).addi(bt))
                            }
                        } else {
                            aZ.w = O;
                            aZ.add(bt, 1);
                            aZ.add(aK);
                            aZ.add(aJ);
                            aZ.add(bt)
                        }
                    }
                    for (bd in X.links) {
                        ay = X.links[bd];
                        aY = O;
                        if (ay.w0 > 0 && ay.w1 > 0) {
                            aY = N
                        }
                        bc = ay.nodes;
                        if (ay.w0 < 0 && ay.w1 < 0) {
                            var aW = aL(0, 1);
                            bk = aW[0];
                            bj = aW[1];
                            var aV = bj.subx(bk),
                                a6 = aH(bk, bj, bg),
                                aB, aF = aV.length(),
                                a9, aA = 1 / aF;
                            T.add(aZ = new g());
                            for (a9 = 0; a9 < aF; a9 += 3) {
                                aB = bk.addx(aV.mulx(aA * a9));
                                aZ.add(aB.addx(a6), 1);
                                aZ.add(aB.subx(a6))
                            }
                        } else {
                            if (!ay.w0 && ay.w1) {
                                aP(0, 1, ay.w1 < 0)
                            } else {
                                if (ay.midPts) {
                                    var bd, bf = ay.midPts,
                                        be = [],
                                        aU = bh(ay, 0),
                                        aS = bh(ay, 1),
                                        Y = aU.clone();
                                    for (bd in bf) {
                                        Y.addi(bf[bd].mulx(ab));
                                        be.push(Y.clone())
                                    }
                                    aU = aQ(ay.nodes[0], aU, be[0]);
                                    aS = aQ(ay.nodes[1], aS, be[be.length - 1]);
                                    be.unshift(aU);
                                    be.push(aS);
                                    T.add(aZ = new I());
                                    aZ.add(be)
                                } else {
                                    if (ay.w0 && !ay.w1) {
                                        aP(1, 0, ay.w0 < 0)
                                    } else {
                                        if (bc.length == 2) {
                                            T.add(aZ = new g());
                                            aZ.w = aY;
                                            var aN = aZ.style = ay.style,
                                                a9, bl, aX = aL(0, 1);
                                            bk = aX[0];
                                            bj = aX[1];
                                            if (ay.N == 2 || ay.N == 3) {
                                                a6 = new Point();
                                                var az = bg * (ay.N - 1);
                                                if (Math.abs(bk.x - bj.x) < Math.abs(bk.y - bj.y)) {
                                                    a6.x = az
                                                } else {
                                                    a6.y = az
                                                }
                                                var a7 = bk.subx(a6),
                                                    aK = bj.subx(a6),
                                                    a5 = bk.addx(a6),
                                                    aJ = bj.addx(a6);
                                                if (ay.N == 2 && ay.cross) {
                                                    var a4 = aK;
                                                    aK = aJ;
                                                    aJ = a4
                                                }
                                                aZ.add(a7, 1);
                                                aZ.add(aK);
                                                aZ.add(a5, 1);
                                                aZ.add(aJ)
                                            }
                                            if (ay.N == 1 || ay.N == 3 || (ay.N == 0 && aN)) {
                                                aZ.add(bk, 1);
                                                aZ.add(bj);

                                                function aM(a2, bn) {
                                                    T.add(aln = new g());
                                                    var bm = bn.subx(a2);
                                                    var j = bm.length();
                                                    bm.muli(aa.arrowX / j);
                                                    var a1 = bn.subx(bm);
                                                    aln.add(bn, 1);
                                                    aln.add(a1.addx(bm.y / 2, -bm.x / 2));
                                                    aln.add(bn, 1);
                                                    aln.add(a1.addx(-bm.y / 2, bm.x / 2))
                                                }
                                                if (ay.arr1) {
                                                    aM(bk, bj)
                                                }
                                                if (ay.arr0) {
                                                    aM(bj, bk)
                                                }
                                            }
                                        } else {
                                            var bi = new Point(),
                                                a0 = [];
                                            for (bb in bc) {
                                                a0.push(bh(ay, bb));
                                                bi.addi(a0[bb])
                                            }
                                            bi.muli(1 / bc.length);
                                            T.add(aZ = new z("circle"));
                                            aZ.c = bi;
                                            aZ.w = O;
                                            var a9, aD, a3 = null,
                                                aT = a0.length;
                                            for (bb = 0; bb < aT; bb++) {
                                                a9 = (bb + 1) % aT;
                                                aD = bi.distSqr(a0[bb].addx(a0[a9]).muli(0.5));
                                                a3 = !a3 ? aD : Math.min(aD)
                                            }
                                            aZ.r = 0.65 * Math.sqrt(a3)
                                        }
                                    }
                                }
                            }
                        }
                        aZ.color = ay.color
                    }
                    if (Z) {
                        W(X)
                    }
                },
                operation: function(Y) {
                    var X = av(Y.dstText, "std", Y);
                    T.add(X);
                    T.c = X.sz.mulx(0.5);
                    if (Y.commentPre) {
                        var j = av(Y.commentPre, "std", Y);
                        T.add(j);
                        j.pos.init((X.sz.x - j.sz.x) / 2, -0.6 * j.sz.y)
                    }
                    if (Y.commentPost) {
                        var j = av(Y.commentPost, "std", Y);
                        T.add(j);
                        j.pos.init((X.sz.x - j.sz.x) / 2, 0.75 * X.sz.y)
                    }
                },
                entityPost: function(j) {
                    W(j)
                }
            });

            function W(ay) {
                T.update();
                var ax, aC = T.c || new Point(),
                    az = T.frms;
                if (az.length) {
                    for (ax in az) {
                        aC.addi(az[ax].pos).addi(az[ax].c)
                    }
                    aC.muli(1 / az.length)
                }
                T.c = aC;
                var aA = aC.y - T.org.y,
                    aD = Math.max(aD, aA),
                    Y = ay.k;
                if (Y && Y != 1) {
                    var X = av(Y, "AgentK", {});
                    T.add(X);
                    var aB = X.sz;
                    aB.x += P.sz.x / 4;
                    X.pos.init(T.org.x - aB.x, aC.y - aB.y / 2);
                    T.update()
                }
            }
            var ai = 0,
                ao, ar;
            for (ao in af.frms) {
                ar = af.frms[ao];
                ar.pos = new Point(ai, ae - (ar.c.y - ar.org.y));
                ai += ar.sz.x + 10
            }
            af.update();
            af.pos.addi(3);
            af.sz.addi(6);
            return af
        };
        var H = {
            fntList: ["std", "half", "Atom", "AgentK", "Custom", "Comment", "OpComment"],
            lineScale: function(i) {}
        };
        this.graphProps = function(O, Y) {
            Y = Y || this.rulesHtml;
            var R, N, S, V = {
                color: "black",
                bkColor: 0,
                fonts: {},
                lineLen: {}
            };
            V.lineLen = {
                line: 30,
                horiz: 10,
                thick: 4,
                width: 1,
                arrowX: 8,
                arrowY: 3,
                dash: 3
            };
            try {
                var U, X, Z, Q, j, W = document.createElement("span");
                O.appendChild(W);
                Z = y.getComputedStyle(W);
                V.color = Z.color;
                if (Z.backgroundColor.indexOf("transparent") < 0) {
                    V.bkColor = Z.backgroundColor
                }
                for (R in H.fntList) {
                    N = H.fntList[R];
                    Q = q(Y, N, "A");
                    W.innerHTML = Q;
                    j = Q.charAt(0) == "<" ? W.firstChild : W;
                    Z = y.getComputedStyle(j);
                    X = Z.fontWeight;
                    U = Z.fontSize;
                    if (/^\d*px$/.test(U)) {
                        U = +(U.substring(0, U.length - 2))
                    } else {
                        U = j.innerHeight
                    }
                    if (N == "half") {
                        U = Math.round(U * 0.6)
                    }
                    V.fonts[N] = {
                        size: U,
                        color: Z.color,
                        family: Z.fontFamily,
                        bold: (+X) ? X > 500 : X == "bold",
                        italic: Z.fontStyle == "italic"
                    }
                }
            } finally {
                if (W) {
                    O.removeChild(W)
                }
            }
            var T = V.fonts.std.size * 1.6,
                P = T / 30;
            for (R in V.lineLen) {
                V.lineLen[R] *= P
            }
            V.prototype = H;
            return V
        };
        this.draw = function(N, V, aa) {
            var O = 0,
                ab = 0;
            try {
                O = document.createElement("CANVAS");
                if (O && O.getContext) {
                    ab = O.getContext("2d")
                }
            } catch (U) {}
            if (!ab) {
                N.innerHTML = this.lang("Browser does not support canvas-graphics");
                return 0
            }
            var X = this.graphProps(N, aa),
                L = X.color,
                W = X.bkColor,
                Q, S, P, T = {};
            for (Q in X.fonts) {
                S = X.fonts[Q];
                T[Q] = P = {
                    fnt: "",
                    h: S.size,
                    color: S.color
                };
                if (S.italic) {
                    P.fnt += "italic "
                }
                if (S.bold) {
                    P.fnt += "bold "
                }
                P.fnt += S.size + "px " + S.family
            }
            try {
                var R = X.lineLen.dash,
                    Z = this.buildFrame(V, {
                        lineLen: X.lineLen,
                        setTextProps: function(ac) {
                            var ad = T[ac.fntId];
                            ab.font = ac.fnt = ad.fnt;
                            var j = ab.measureText(ac.text);
                            if (!j) {
                                ac.sz.init(ad.h * 0.6, ad.h)
                            } else {
                                ac.sz.init(j.width, ad.h)
                            }
                            ac.color = ad.color
                        }
                    });
                O.width = Z.sz.x;
                O.height = Z.sz.y;
                ab.textBaseline = "top";
                ab.textAlign = "left";
                if (W) {
                    ab.fillStyle = W;
                    ab.fillRect(0, 0, Z.sz.x, Z.sz.y)
                }

                function i(af, ac, av) {
                    var ar, ap, ah, ak, aj, ae, an = ac.subx(af.org).addx(af.pos);
                    for (ar in af.frms) {
                        i(af.frms[ar], an, av)
                    }
                    for (ar in af.prims) {
                        ah = af.prims[ar];
                        if (ah.type == "text" && av) {
                            aj = an.addx(ah.pos);
                            ab.fillStyle = ah.color || L;
                            ab.font = ah.fnt;
                            ab.fillText(ah.text, aj.x, aj.y)
                        } else {
                            if (ah.type == "curve") {
                                var ag = [];
                                for (ap in ah.pts) {
                                    ag[ap] = ah.pts[ap].addx(an)
                                }
                                ab.moveTo(ag[0].x, ag[0].y);
                                if (ag.length == 3) {
                                    ab.quadraticCurveTo(ag[1].x, ag[1].y, ag[2].x, ag[2].y)
                                } else {
                                    if (ag.length == 4) {
                                        ab.bezierCurveTo(ag[1].x, ag[1].y, ag[2].x, ag[2].y, ag[3].x, ag[3].y)
                                    }
                                }
                                ab.strokeStyle = ah.color || L;
                                ab.stroke()
                            } else {
                                if (ah.type == "lines" && !av) {
                                    ab.lineWidth = ah.w;
                                    ab.beginPath();
                                    for (ap in ah.pts) {
                                        ak = ah.pts[ap];
                                        aj = an.addx(ak);
                                        if (ah.style == ":") {
                                            if (ak.mv) {
                                                ae = ak
                                            } else {
                                                var ag = ak.subx(ae),
                                                    at = ag.length();
                                                var ao, aq = at / R / 2;
                                                for (ao = 0; ao < aq; ao++) {
                                                    var aw = an.addx(ae.addx(ag.mulx(ao / aq)));
                                                    var au = aw.addx(ag.mulx(R / at));
                                                    ab.moveTo(aw.x, aw.y);
                                                    ab.lineTo(au.x, au.y)
                                                }
                                            }
                                        } else {
                                            if (ah.style == "~") {
                                                if (ak.mv) {
                                                    ae = aj
                                                } else {
                                                    var aw = ae.clone(),
                                                        au, al, ai;
                                                    var ag = aj.subx(ae),
                                                        at = ag.length(),
                                                        am = X.lineLen.line / 6,
                                                        ax = Math.floor((at + am / 2) / am),
                                                        ad = ag.mulx(am / at);
                                                    at /= ax;
                                                    ag.muli(1 / ax);
                                                    ab.moveTo(aw.x, aw.y);
                                                    for (ao = 0; ao < ax; ao++) {
                                                        au = aw.addx(ag);
                                                        if ((ao & 1) == 0) {
                                                            al = aw.addx(ad.y, -ad.x)
                                                        } else {
                                                            al = aw.addx(-ad.y, ad.x)
                                                        }
                                                        ai = al.addx(ag);
                                                        ab.bezierCurveTo(al.x, al.y, ai.x, ai.y, au.x, au.y);
                                                        aw = au
                                                    }
                                                }
                                            } else {
                                                if (ak.mv) {
                                                    ab.moveTo(aj.x, aj.y)
                                                } else {
                                                    ab.lineTo(aj.x, aj.y)
                                                }
                                            }
                                        }
                                    }
                                    if (ah.bFill) {
                                        ab.fillStyle = ah.color || L;
                                        ab.fill()
                                    }
                                    ab.strokeStyle = ah.color || L;
                                    ab.stroke()
                                } else {
                                    if (ah.type == "circle" && !av) {
                                        ab.beginPath();
                                        aj = an.addx(ah.c);
                                        ab.arc(aj.x, aj.y, ah.r, 0, 2 * Math.PI, false);
                                        if (ah.bFill) {
                                            ab.fillStyle = ah.color || L;
                                            ab.fill()
                                        }
                                        ab.strokeStyle = ah.color || L;
                                        ab.stroke()
                                    }
                                }
                            }
                        }
                    }
                }
                var Y = new Point(0);
                i(Z, Y, 0);
                ab.stroke();
                i(Z, Y, 1);
                N.appendChild(O);
                return 1
            } catch (U) {
                N.innerHTML = "Error: " + U.message;
                return 0
            }
        }
    }(),
    ChemJQ = {
        draw: function(b, a) {
            var c = jQuery(a).empty();
            if (b.isOk && !b.isOk()) {
                return
            }
            if (b.isLinear()) {
                c.html(ChemSys.makeHtml(b))
            } else {
                ChemSys.draw(c[0], b)
            }
        },
        autoCompileSingle: function(a) {
            var b = $(a).text();
            this.draw(ChemSys.compile(b), a)
        },
        autoCompile: function(a) {
            a = a || ".echem-formula";
            jQuery(a).each(function() {
                ChemJQ.autoCompileSingle(this)
            })
        }
    };
if ("jQuery" in window) {
    jQuery(function() {
        if (jQuery("body").hasClass("echem-auto-compile") || jQuery(".easyChemConfig").hasClass("auto-compile")) {
            ChemJQ.autoCompile()
        }
    })
}

function Macros(a) {
    this.name = a;
    this.body = "";
    this.exec = function(b) {
        return this.body
    }
}

function scanPar(d, f) {
    var e, a = 0,
        b = 0;
    while (f < d.length) {
        e = d.charAt(f);
        if (e == '"') {
            b = !b
        } else {
            if (e == "(" && !b) {
                a++
            } else {
                if (e == "," && !b && a == 0) {
                    break
                } else {
                    if (e == ")" && !b) {
                        if (a > 0) {
                            a--
                        } else {
                            break
                        }
                    }
                }
            }
        }
        f++
    }
    return f
}

function preProcess(b) {
    var j = /[A-Z]/i,
        c = /^[A-Z][A-Z\d]*$/i;

    function h(e) {
        $("<div/>").html(e).appendTo("#Debug")
    }

    function o(p, e) {
        this.src = "";
        this.dst = "";
        this.stk = [];
        this.pos = 0;
        if (p instanceof o) {
            this.src = p.src;
            this.pos = p.pos
        } else {
            if (typeof p == "string") {
                this.src = p;
                if (e) {
                    this.pos = e
                }
            }
        }
    }
    o.prototype = {
        err: function(q, u) {
            if (u) {
                if (u < 0) {
                    this.pos += u
                } else {
                    this.pos = u
                }
            }
            h("<b>Error:</b> " + q);
            var e = this.src.substring(0, m.pos),
                p = this.src.substring(m.pos);
            h("in position " + (this.pos + 1) + ": " + e + "<b>&lt;!&gt;</b>" + p);
            throw new Error(q)
        },
        n: function(q) {
            if (q === 0) {
                return ""
            }
            if (!q) {
                q = 1
            }
            if (this.pos + q > this.src.length) {
                this.err("Unexpected end of macros")
            }
            var p = this.pos,
                e = p + q,
                r = this.src.substring(p, e);
            this.pos = e;
            return r
        },
        s: function(p, r) {
            var q = this.pos,
                e = this.src.indexOf(p, q);
            if (e < 0) {
                if (r) {
                    return null
                }
                this.err("Expected " + p + " character in macros")
            }
            this.pos = e + p.length;
            if (q == e) {
                return ""
            }
            return this.src.substring(q, e)
        },
        end: function() {
            return this.pos < this.src.length
        },
        w: function(e) {
            this.dst += e
        },
        wf: function() {
            this.w(this.src.substring(this.pos));
            this.pos = this.src.length
        },
        push: function() {
            this.stk.push(this.dst);
            this.dst = ""
        },
        pop: function() {
            var e = this.dst;
            this.dst = this.stk.pop();
            return e
        },
        clr: function() {
            this.dst = ""
        }
    };

    function f(e) {
        var u, r = e.pos,
            p = e.s("("),
            q = new Macros(p);
        if (!j.test(p.charAt(0))) {
            e.err("Invalid macro name", r)
        }
        e.push();
        a(e);
        q.body = e.pop();
        u = e.n();
        if (u == ";") {} else {
            if (u == "(") {
                e.w("@" + p + u)
            } else {
                e.err("Invalid macros end")
            }
        }
        ChemSys.macros[p] = q
    }

    function i(e, r) {
        e.pos--;
        var q = 0;
        do {
            var x = e.pos,
                v = scanPar(e.src, x);
            if (v >= e.src.length) {
                e.err("Real params list is not closed")
            }
            var u = e.n(v - x),
                w = e.n();
            r[q++] = u;
            if (w == ")") {
                break
            }
        } while (1)
    }

    function n(y, v, u) {
        y.pos--;
        while (1) {
            var p, r, e, q, x = y.pos,
                w = scanPar(y.src, x);
            if (w >= y.src.length) {
                y.err("Formal params list is not closed")
            }
            q = y.n(w - x);
            p = q.indexOf(":");
            if (p < 0) {
                e = q;
                q = ""
            } else {
                e = q.substring(0, p);
                q = q.substring(p + 1)
            }
            if (!c.test(e)) {
                y.err("Invalid parameter name: " + esc(e))
            }
            v[e] = q;
            u.push(e);
            r = y.n();
            if (r == ")") {
                break
            }
        }
    }

    function g(e, v) {
        var E = new o(e);
        var B = E.n(),
            D = {},
            C = [];
        if (B != ")") {
            n(E, D, C)
        }
        if (C.length > 0) {
            var w, q, A, y, x = 0,
                z;
            for (y in v) {
                A = v[y];
                w = A.indexOf(":");
                if (w > 0) {
                    q = A.substring(0, w);
                    if (q in D) {
                        D[q] = A.substring(w + 1);
                        continue
                    }
                }
                q = C[x++];
                if (A) {
                    D[q] = A
                }
            }
            E.wf();
            z = E.dst.split("&");
            for (y = 1; y < z.length; y++) {
                q = "";
                for (A in D) {
                    if (z[y].substring(0, A.length) == A && A.length > q.length) {
                        q = A
                    }
                }
                if (!q) {
                    continue
                }
                z[y] = D[q] + z[y].substring(q.length)
            }
            E = new o("");
            for (y in z) {
                E.src += z[y]
            }
        }
        while (1) {
            B = E.s("@", 1);
            if (B === null) {
                E.wf();
                break
            }
            E.w(B);
            B = E.n();
            if (!j.test(B)) {
                E.err("Invalid macro")
            }
            var p = B + E.s("(");
            var u = ChemSys.macros[p];
            if (!u) {
                E.err("Macros not found: " + p)
            }
            var r = {};
            B = E.n();
            if (B != ")") {
                i(E, r)
            }
            E.w(g(u.body, r))
        }
        return E.dst
    }

    function a(e) {
        var q, p;
        while (1) {
            p = e.s("@", 1);
            if (p === null) {
                e.wf();
                break
            }
            e.w(p);
            q = e.n();
            if (q == ":") {
                f(e)
            } else {
                if (j.test(q)) {
                    e.w("@" + q);
                    continue
                } else {
                    e.pos--;
                    break
                }
            }
        }
    }
    try {
        var m = new o(b);
        a(m);
        if (m.pos != b.length) {
            m.err("Invalid preprocessor finish")
        }
    } catch (l) {
        return {
            ok: 0,
            msg: l.message,
            pos: m.pos
        }
    }
    var d = ")" + m.dst;
    try {
        return {
            ok: 1,
            dst: g(d, {})
        }
    } catch (l) {
        return {
            ok: 0,
            msg: "Runtime error: " + l.message
        }
    }
};