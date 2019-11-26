import { CClassA } from "./RequireA";

export class CClassB {
    mem_name: string;
    mem_obj: CClassA | undefined;

    constructor() {
        this.mem_name = "Instance of B";
    }

    setObj(obj:CClassA): void {
        this.mem_obj = obj;
    }

    name():string {
        return this.mem_name;
    }
    
    showObj():void {
        if (this.mem_obj)
            console.log("name of obj from CClassB is " + this.mem_obj.name());
        console.log("ClassA foo ", CClassA.foo())
    }

    static foo(): string {
        return "hello B";
    }
}

export class CClassD extends CClassA {
    static foo(): string {
        return "hello D";
    }

}