import { CClassB } from "./RequireB";

export class CClassA {
    mem_name: string;
    mem_obj: CClassB | undefined;
    
    constructor(){
        this.mem_name = "Instance of A";
    }

    setObj(obj:CClassB): void{
        this.mem_obj = obj;
    }

    name():string {
        return this.mem_name;
    }

    showObj():void {
        if (this.mem_obj)
            console.log("name of obj from CClassA is " + this.mem_obj.name());
        console.log("ClassB foo", CClassB.foo())
    }

    static foo(): string {
        return "hello A";
    }
}

export class CClassC extends CClassB {
    static foo(): string {
        return "hello C";
    }
}