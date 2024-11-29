import java.awt.Image
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

fun main() {
    val sourceImage = "app/src/main/res/app_icon/img.jpg"  // Update this path to your image
    val sizes = mapOf(
        "mdpi" to 48,
        "hdpi" to 72,
        "xhdpi" to 96,
        "xxhdpi" to 144,
        "xxxhdpi" to 192
    )

    val inputImage = ImageIO.read(File(sourceImage))

    sizes.forEach { (density, size) ->
        val resized = resizeImage(inputImage, size, size)
        val outputDir = File("app/src/main/res/mipmap-$density")
        outputDir.mkdirs()
        
        // Save regular icon
        val outputFile = File(outputDir, "ic_launcher.png")
        ImageIO.write(resized, "PNG", outputFile)
        
        // Save round icon
        val roundOutputFile = File(outputDir, "ic_launcher_round.png")
        ImageIO.write(resized, "PNG", roundOutputFile)
        
        println("Created icon for $density: ${outputFile.absolutePath}")
    }
}

fun resizeImage(originalImage: BufferedImage, targetWidth: Int, targetHeight: Int): BufferedImage {
    val resultingImage = BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_ARGB)
    val graphics2D = resultingImage.createGraphics()
    graphics2D.drawImage(originalImage.getScaledInstance(targetWidth, targetHeight, Image.SCALE_SMOOTH), 0, 0, null)
    graphics2D.dispose()
    return resultingImage
} 