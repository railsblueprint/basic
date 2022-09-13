import {Controller} from "@hotwired/stimulus";
import {DataTable} from "simple-datatables"

export default class extends Controller {
    connect() {
        this.dataTable = new DataTable(this.element);
    }


}
