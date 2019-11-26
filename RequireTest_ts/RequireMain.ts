import { CClassA, CClassC } from "./RequireA";
import { CClassB, CClassD } from "./RequireB";

let b = new CClassC();
let a = new CClassD();

a.setObj(b);
b.setObj(a);

a.showObj()
b.showObj()
