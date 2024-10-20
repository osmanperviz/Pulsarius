export const UploadArea = {
  mounted() {
    this.el.addEventListener("click", (event) => {
      if (event.target.closest(".remove-btn")) {
        event.preventDefault();
        return;
      }

      if (event.target.closest(".remove-uploaded-logo")) {
        event.preventDefault();
        return;
      }

      // Find the file input inside the upload area and trigger the click event
      const fileInput = this.el.querySelector("input[type='file']");
      if (fileInput) {
        fileInput.click();
      }
    });
  },
};
